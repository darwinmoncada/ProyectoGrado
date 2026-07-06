package com.uts.inventario.service;

import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.ColumnText;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPageEventHelper;
import com.lowagie.text.pdf.PdfTemplate;
import com.lowagie.text.pdf.PdfWriter;
import com.uts.inventario.entity.Asset;
import com.uts.inventario.entity.InventoryMovement;
import com.uts.inventario.entity.User;
import com.uts.inventario.exception.ResourceNotFoundException;
import com.uts.inventario.repository.AssetRepository;
import com.uts.inventario.repository.InventoryMovementRepository;
import com.uts.inventario.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Genera reportes PDF con identidad corporativa institucional (UTS) usando OpenPDF:
 * encabezado con logo y título, pie de página con responsable/fecha y numeración
 * "Página X de Y" en todas las páginas.
 */
@Service
@RequiredArgsConstructor
public class PdfReportService {

    private final AssetRepository assetRepository;
    private final InventoryMovementRepository inventoryMovementRepository;

    private static final Color COLOR_PRIMARY = new Color(21, 101, 192);
    private static final Color COLOR_ROW_ALT = new Color(245, 247, 250);
    private static final Color COLOR_TEXT_MUTED = new Color(100, 100, 100);
    private static final Color COLOR_BORDER = new Color(220, 224, 230);

    private static final Font FONT_TITLE = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16, COLOR_PRIMARY);
    private static final Font FONT_SUBTITLE = FontFactory.getFont(FontFactory.HELVETICA, 9, COLOR_TEXT_MUTED);
    private static final Font FONT_SECTION = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, COLOR_PRIMARY);
    private static final Font FONT_TABLE_HEADER = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 9, Color.WHITE);
    private static final Font FONT_TABLE_CELL = FontFactory.getFont(FontFactory.HELVETICA, 9, Color.BLACK);
    private static final Font FONT_LABEL = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 9, COLOR_TEXT_MUTED);
    private static final Font FONT_VALUE = FontFactory.getFont(FontFactory.HELVETICA, 10, Color.BLACK);
    private static final Font FONT_FOOTER = FontFactory.getFont(FontFactory.HELVETICA, 8, COLOR_TEXT_MUTED);

    private static final DateTimeFormatter DATETIME_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    @Transactional(readOnly = true)
    public byte[] generateAssetListReport(List<Long> assetIds) {
        List<Asset> assets = assetRepository.findAllById(assetIds);
        if (assets.isEmpty()) {
            throw new ResourceNotFoundException("No se encontraron activos para exportar");
        }

        Document document = new Document(PageSize.A4, 36, 36, 95, 55);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try {
            PdfWriter writer = PdfWriter.getInstance(document, out);
            writer.setPageEvent(new CorporateHeaderFooter("Reporte de Activos Tecnológicos"));
            document.open();

            addSectionTitle(document, "Activos Seleccionados (" + assets.size() + ")");
            addAssetsTable(document, assets);

            List<InventoryMovement> movements = assets.stream()
                    .flatMap(a -> inventoryMovementRepository.findByAssetIdOrderByMovementDateDesc(a.getId()).stream())
                    .toList();

            if (!movements.isEmpty()) {
                document.newPage();
                addSectionTitle(document, "Historial Consolidado de Movimientos");
                addMovementsTable(document, movements);
            }

            document.close();
        } catch (DocumentException e) {
            throw new IllegalStateException("Error al generar el PDF del reporte de activos", e);
        }
        return out.toByteArray();
    }

    @Transactional(readOnly = true)
    public byte[] generateAssetDetailSheet(Long assetId) {
        Asset asset = assetRepository.findById(assetId)
                .orElseThrow(() -> new ResourceNotFoundException("Activo no encontrado con id: " + assetId));
        List<InventoryMovement> movements = inventoryMovementRepository.findByAssetIdOrderByMovementDateDesc(assetId);

        Document document = new Document(PageSize.A4, 36, 36, 95, 55);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try {
            PdfWriter writer = PdfWriter.getInstance(document, out);
            writer.setPageEvent(new CorporateHeaderFooter("Hoja de Vida de Equipo"));
            document.open();

            addAssetDetailSheet(document, asset, movements);

            document.close();
        } catch (DocumentException e) {
            throw new IllegalStateException("Error al generar la ficha PDF del activo", e);
        }
        return out.toByteArray();
    }

    // ---------- Contenido: reporte de lista ----------

    private void addAssetsTable(Document document, List<Asset> assets) throws DocumentException {
        PdfPTable table = new PdfPTable(new float[]{1.2f, 2.2f, 1.3f, 1.3f, 1.6f, 1.6f, 1.3f});
        table.setWidthPercentage(100);
        table.setSpacingBefore(6);

        addHeaderCell(table, "Código");
        addHeaderCell(table, "Nombre");
        addHeaderCell(table, "Marca");
        addHeaderCell(table, "Modelo");
        addHeaderCell(table, "Tipo");
        addHeaderCell(table, "Área");
        addHeaderCell(table, "Estado");

        boolean alternate = false;
        for (Asset asset : assets) {
            Color bg = alternate ? COLOR_ROW_ALT : Color.WHITE;
            addBodyCell(table, valueOrDash(asset.getCodigo()), bg);
            addBodyCell(table, valueOrDash(asset.getName()), bg);
            addBodyCell(table, valueOrDash(asset.getBrand()), bg);
            addBodyCell(table, valueOrDash(asset.getModel()), bg);
            addBodyCell(table, asset.getAssetType() != null ? asset.getAssetType().getName() : "Sin asignar", bg);
            addBodyCell(table, asset.getArea() != null ? asset.getArea().getName() : "Sin asignar", bg);
            addBodyCell(table, asset.getStatus().getLabel(), bg);
            alternate = !alternate;
        }

        document.add(table);
    }

    private void addMovementsTable(Document document, List<InventoryMovement> movements) throws DocumentException {
        PdfPTable table = new PdfPTable(new float[]{1.6f, 1.4f, 1.3f, 1.3f, 1.3f, 1.4f, 1.7f});
        table.setWidthPercentage(100);
        table.setSpacingBefore(6);

        addHeaderCell(table, "Activo");
        addHeaderCell(table, "Fecha");
        addHeaderCell(table, "Tipo");
        addHeaderCell(table, "Área Origen");
        addHeaderCell(table, "Área Destino");
        addHeaderCell(table, "Usuario");
        addHeaderCell(table, "Observaciones");

        boolean alternate = false;
        for (InventoryMovement m : movements) {
            Color bg = alternate ? COLOR_ROW_ALT : Color.WHITE;
            addBodyCell(table, m.getAsset() != null ? valueOrDash(m.getAsset().getName()) : "Sin asignar", bg);
            addBodyCell(table, m.getMovementDate().format(DATETIME_FORMAT), bg);
            addBodyCell(table, m.getMovementType().getLabel(), bg);
            addBodyCell(table, m.getFromArea() != null ? m.getFromArea().getName() : "Sin asignar", bg);
            addBodyCell(table, m.getToArea() != null ? m.getToArea().getName() : "Sin asignar", bg);
            String user = m.getToUser() != null ? m.getToUser().getFullName()
                    : m.getFromUser() != null ? m.getFromUser().getFullName() : "Sin asignar";
            addBodyCell(table, user, bg);
            String observations = m.getNotes() != null && !m.getNotes().isBlank() ? m.getNotes()
                    : (m.getReason() != null && !m.getReason().isBlank() ? m.getReason() : "Sin observaciones");
            addBodyCell(table, observations, bg);
            alternate = !alternate;
        }

        document.add(table);
    }

    // ---------- Contenido: ficha individual ----------

    private void addAssetDetailSheet(Document document, Asset asset, List<InventoryMovement> movements) throws DocumentException {
        Paragraph subtitle = new Paragraph(asset.getName() + " · " + valueOrDash(asset.getCodigo()), FONT_SECTION);
        subtitle.setSpacingAfter(10);
        document.add(subtitle);

        addSectionTitle(document, "Datos del Activo");
        PdfPTable dataTable = createGridTable();
        addGridRow(dataTable, "Nombre", asset.getName());
        addGridRow(dataTable, "Marca / Modelo", joinOrDash(asset.getBrand(), asset.getModel()));
        addGridRow(dataTable, "Número de Serie", asset.getSerialNumber());
        addGridRow(dataTable, "Código Interno", asset.getCodigo());
        addGridRow(dataTable, "Tipo de Activo", asset.getAssetType() != null ? asset.getAssetType().getName() : null);
        addGridRow(dataTable, "Categoría", asset.getAssetType() != null ? asset.getAssetType().getCategory() : null);
        addGridRow(dataTable, "Estado", asset.getStatus().getLabel());
        document.add(dataTable);

        addSectionTitle(document, "Asignación");
        PdfPTable assignTable = createGridTable();
        addGridRow(assignTable, "Área", asset.getArea() != null ? asset.getArea().getName() : null);
        addGridRow(assignTable, "Ubicación", asset.getArea() != null ? asset.getArea().getLocation() : null);
        addGridRow(assignTable, "Usuario Asignado", asset.getAssignedUser() != null ? asset.getAssignedUser().getFullName() : null);
        addGridRow(assignTable, "Correo del Usuario", asset.getAssignedUser() != null ? asset.getAssignedUser().getEmail() : null);
        document.add(assignTable);

        if (asset.getSpecifications() != null && !asset.getSpecifications().isBlank()) {
            addSectionTitle(document, "Especificaciones Técnicas");
            Paragraph specs = new Paragraph(asset.getSpecifications(), FONT_VALUE);
            specs.setSpacingAfter(10);
            document.add(specs);
        }

        if (asset.getNetworkDevice() != null) {
            addSectionTitle(document, "Configuración de Red");
            PdfPTable netTable = createGridTable();
            addGridRow(netTable, "Dirección IP", asset.getNetworkDevice().getIpAddress());
            addGridRow(netTable, "Dirección MAC", asset.getNetworkDevice().getMacAddress());
            addGridRow(netTable, "Hostname", asset.getNetworkDevice().getHostname());
            addGridRow(netTable, "Estado de Red", asset.getNetworkDevice().getNetworkStatus() != null
                    ? asset.getNetworkDevice().getNetworkStatus().getLabel() : null);
            document.add(netTable);
        }

        if (!movements.isEmpty()) {
            addSectionTitle(document, "Historial de Movimientos");
            addMovementsTable(document, movements);
        }

        addSignatureBlock(document);
    }

    private void addSignatureBlock(Document document) throws DocumentException {
        Paragraph spacer = new Paragraph(" ");
        spacer.setSpacingBefore(30);
        document.add(spacer);

        PdfPTable signatureTable = new PdfPTable(2);
        signatureTable.setWidthPercentage(75);
        signatureTable.setHorizontalAlignment(Element.ALIGN_LEFT);

        signatureTable.addCell(borderlessCell("_____________________________", FONT_VALUE, 24f));
        signatureTable.addCell(borderlessCell("_____________________________", FONT_VALUE, 24f));
        signatureTable.addCell(borderlessCell("Firma de quien entrega", FONT_LABEL, 2f));
        signatureTable.addCell(borderlessCell("Firma de quien revisa / recibe", FONT_LABEL, 2f));

        document.add(signatureTable);
    }

    private PdfPCell borderlessCell(String text, Font font, float paddingTop) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBorder(Rectangle.NO_BORDER);
        cell.setPaddingTop(paddingTop);
        return cell;
    }

    // ---------- Utilidades de tabla ----------

    private PdfPTable createGridTable() throws DocumentException {
        PdfPTable table = new PdfPTable(2);
        table.setWidths(new float[]{1f, 2f});
        table.setWidthPercentage(100);
        table.setSpacingBefore(4);
        table.setSpacingAfter(12);
        return table;
    }

    private void addGridRow(PdfPTable table, String label, String value) {
        PdfPCell labelCell = new PdfPCell(new Phrase(label, FONT_LABEL));
        labelCell.setBackgroundColor(COLOR_ROW_ALT);
        labelCell.setBorderColor(COLOR_BORDER);
        labelCell.setPadding(6);

        PdfPCell valueCell = new PdfPCell(new Phrase(valueOrDash(value), FONT_VALUE));
        valueCell.setBorderColor(COLOR_BORDER);
        valueCell.setPadding(6);

        table.addCell(labelCell);
        table.addCell(valueCell);
    }

    private void addHeaderCell(PdfPTable table, String text) {
        PdfPCell cell = new PdfPCell(new Phrase(text, FONT_TABLE_HEADER));
        cell.setBackgroundColor(COLOR_PRIMARY);
        cell.setPadding(6);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        table.addCell(cell);
    }

    private void addBodyCell(PdfPTable table, String text, Color background) {
        PdfPCell cell = new PdfPCell(new Phrase(text, FONT_TABLE_CELL));
        cell.setBackgroundColor(background);
        cell.setBorderColor(COLOR_BORDER);
        cell.setPadding(5);
        table.addCell(cell);
    }

    private void addSectionTitle(Document document, String title) throws DocumentException {
        Paragraph paragraph = new Paragraph(title, FONT_SECTION);
        paragraph.setSpacingBefore(14);
        paragraph.setSpacingAfter(6);
        document.add(paragraph);
    }

    private String valueOrDash(String value) {
        return value != null && !value.isBlank() ? value : "Sin asignar";
    }

    private String joinOrDash(String a, String b) {
        String joined = String.format("%s %s", a != null ? a : "", b != null ? b : "").trim();
        return joined.isEmpty() ? "Sin asignar" : joined;
    }

    // ---------- Encabezado / pie de página corporativo ----------

    private static class CorporateHeaderFooter extends PdfPageEventHelper {
        private final String reportTitle;
        private Image logo;
        private PdfTemplate totalPagesTemplate;

        CorporateHeaderFooter(String reportTitle) {
            this.reportTitle = reportTitle;
            try {
                ClassPathResource resource = new ClassPathResource("branding/logo-uts.png");
                logo = Image.getInstance(resource.getURL());
                logo.scaleToFit(85, 42);
            } catch (Exception e) {
                logo = null;
            }
        }

        @Override
        public void onOpenDocument(PdfWriter writer, Document document) {
            totalPagesTemplate = writer.getDirectContent().createTemplate(50, 20);
        }

        @Override
        public void onEndPage(PdfWriter writer, Document document) {
            PdfContentByte cb = writer.getDirectContent();
            float pageWidth = document.getPageSize().getWidth();
            float pageHeight = document.getPageSize().getHeight();
            float headerBaseline = pageHeight - 30;

            if (logo != null) {
                try {
                    logo.setAbsolutePosition(36, headerBaseline - 32);
                    cb.addImage(logo);
                } catch (Exception ignored) {
                    // Si falla el dibujo puntual del logo, el resto del encabezado se dibuja igual.
                }
            }

            ColumnText.showTextAligned(cb, Element.ALIGN_RIGHT, new Phrase(reportTitle, FONT_TITLE),
                    pageWidth - 36, headerBaseline - 6, 0);
            ColumnText.showTextAligned(cb, Element.ALIGN_RIGHT,
                    new Phrase("Sistema de Inventario TI · Unidades Tecnológicas de Santander", FONT_SUBTITLE),
                    pageWidth - 36, headerBaseline - 22, 0);

            cb.setColorStroke(COLOR_PRIMARY);
            cb.setLineWidth(1f);
            cb.moveTo(36, headerBaseline - 40);
            cb.lineTo(pageWidth - 36, headerBaseline - 40);
            cb.stroke();

            User currentUser = SecurityUtils.getCurrentUser();
            String responsible = currentUser != null ? currentUser.getFullName() : "Sistema";
            String generatedAt = "Generado: " + LocalDateTime.now().format(DATETIME_FORMAT) + "  ·  Emitido por: " + responsible;

            ColumnText.showTextAligned(cb, Element.ALIGN_LEFT, new Phrase(generatedAt, FONT_FOOTER), 36, 25, 0);

            String pageText = "Página " + writer.getPageNumber() + " de ";
            float pageTextWidth = FONT_FOOTER.getBaseFont().getWidthPoint(pageText, FONT_FOOTER.getSize());
            float baseX = pageWidth - 36 - pageTextWidth - 20;

            cb.beginText();
            cb.setFontAndSize(FONT_FOOTER.getBaseFont(), FONT_FOOTER.getSize());
            cb.setTextMatrix(baseX, 25);
            cb.showText(pageText);
            cb.endText();
            cb.addTemplate(totalPagesTemplate, baseX + pageTextWidth, 25);

            cb.setColorStroke(COLOR_BORDER);
            cb.setLineWidth(0.5f);
            cb.moveTo(36, 35);
            cb.lineTo(pageWidth - 36, 35);
            cb.stroke();
        }

        @Override
        public void onCloseDocument(PdfWriter writer, Document document) {
            totalPagesTemplate.beginText();
            totalPagesTemplate.setFontAndSize(FONT_FOOTER.getBaseFont(), FONT_FOOTER.getSize());
            totalPagesTemplate.setTextMatrix(0, 0);
            totalPagesTemplate.showText(String.valueOf(writer.getPageNumber() - 1));
            totalPagesTemplate.endText();
        }
    }
}
