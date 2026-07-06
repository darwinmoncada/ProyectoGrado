-- ============================================================================
-- Corrección de corrupción de codificación (tildes/eñes -> '?' literal)
-- ----------------------------------------------------------------------------
-- Causa raíz: el dump importado desde Neon se generó/redirigió con una
-- codificación distinta a UTF-8, y cada carácter acentuado o "ñ" quedó
-- reemplazado por el byte '?' (0x3F) literal. Es pérdida de datos: no se
-- puede "recalcular" la tilde original, solo reponerla por diccionario a
-- partir del texto real de este inventario (nombres de activos/áreas ya
-- verificados manualmente contra la base de datos local).
--
-- Cada UPDATE reemplaza UN fragmento de palabra a la vez y solo toca las filas
-- donde ese fragmento realmente aparece (WHERE columna LIKE '%fragmento%'),
-- así que el script es idempotente: correrlo dos veces no tiene efecto
-- adicional una vez corregidos los datos.
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- areas.name
-- ---------------------------------------------------------------------------
UPDATE areas SET name = replace(name, 'Coordinaci??n', 'Coordinación') WHERE name LIKE '%Coordinaci??n%';
UPDATE areas SET name = replace(name, 'Almac??n', 'Almacén') WHERE name LIKE '%Almac??n%';
UPDATE areas SET name = replace(name, 'Rector??a', 'Rectoría') WHERE name LIKE '%Rector??a%';
UPDATE areas SET name = replace(name, 'Direcci??n', 'Dirección') WHERE name LIKE '%Direcci??n%';
UPDATE areas SET name = replace(name, 'Acad??mica', 'Académica') WHERE name LIKE '%Acad??mica%';

-- ---------------------------------------------------------------------------
-- areas.description
-- ---------------------------------------------------------------------------
UPDATE areas SET description = replace(description, 'informaci??n', 'información') WHERE description LIKE '%informaci??n%';
UPDATE areas SET description = replace(description, 'asignaci??n', 'asignación') WHERE description LIKE '%asignaci??n%';
UPDATE areas SET description = replace(description, 'almac??n', 'almacén') WHERE description LIKE '%almac??n%';
UPDATE areas SET description = replace(description, 'direcci??n', 'dirección') WHERE description LIKE '%direcci??n%';
UPDATE areas SET description = replace(description, 'acad??mica', 'académica') WHERE description LIKE '%acad??mica%';
UPDATE areas SET description = replace(description, 'inform??tica', 'informática') WHERE description LIKE '%inform??tica%';
UPDATE areas SET description = replace(description, '??rea', 'Área') WHERE description LIKE '%??rea%';
UPDATE areas SET description = replace(description, 'preparaci??n', 'preparación') WHERE description LIKE '%preparaci??n%';
UPDATE areas SET description = replace(description, 'rector??a', 'rectoría') WHERE description LIKE '%rector??a%';

-- ---------------------------------------------------------------------------
-- areas.location
-- ---------------------------------------------------------------------------
UPDATE areas SET location = replace(location, 'S??tano', 'Sótano') WHERE location LIKE '%S??tano%';

-- ---------------------------------------------------------------------------
-- asset_types.name
-- ---------------------------------------------------------------------------
UPDATE asset_types SET name = replace(name, 'Port??til', 'Portátil') WHERE name LIKE '%Port??til%';
UPDATE asset_types SET name = replace(name, 'Tel??fono', 'Teléfono') WHERE name LIKE '%Tel??fono%';
UPDATE asset_types SET name = replace(name, 'C??mara', 'Cámara') WHERE name LIKE '%C??mara%';
UPDATE asset_types SET name = replace(name, 'Botiqu??n', 'Botiquín') WHERE name LIKE '%Botiqu??n%';
UPDATE asset_types SET name = replace(name, 'Perif??rico', 'Periférico') WHERE name LIKE '%Perif??rico%';

-- ---------------------------------------------------------------------------
-- asset_types.description
-- ---------------------------------------------------------------------------
UPDATE asset_types SET description = replace(description, 'port??til', 'portátil') WHERE description LIKE '%port??til%';
UPDATE asset_types SET description = replace(description, 'conmutaci??n', 'conmutación') WHERE description LIKE '%conmutaci??n%';
UPDATE asset_types SET description = replace(description, 'C??mara', 'Cámara') WHERE description LIKE '%C??mara%';
UPDATE asset_types SET description = replace(description, 'certificaci??n', 'certificación') WHERE description LIKE '%certificaci??n%';
UPDATE asset_types SET description = replace(description, 'perif??ricos', 'periféricos') WHERE description LIKE '%perif??ricos%';
UPDATE asset_types SET description = replace(description, '??ptica', 'óptica') WHERE description LIKE '%??ptica%';
UPDATE asset_types SET description = replace(description, 'c??mputo', 'cómputo') WHERE description LIKE '%c??mputo%';
UPDATE asset_types SET description = replace(description, 'alimentaci??n', 'alimentación') WHERE description LIKE '%alimentaci??n%';
UPDATE asset_types SET description = replace(description, 'met??lico', 'metálico') WHERE description LIKE '%met??lico%';
UPDATE asset_types SET description = replace(description, 'Tel??fono', 'Teléfono') WHERE description LIKE '%Tel??fono%';

-- ---------------------------------------------------------------------------
-- assets.name
-- ---------------------------------------------------------------------------
UPDATE assets SET name = replace(name, 'Tel??fono', 'Teléfono') WHERE name LIKE '%Tel??fono%';
UPDATE assets SET name = replace(name, 'C??mara', 'Cámara') WHERE name LIKE '%C??mara%';
UPDATE assets SET name = replace(name, 'Botiqu??n', 'Botiquín') WHERE name LIKE '%Botiqu??n%';
UPDATE assets SET name = replace(name, 'Pa??o', 'Paño') WHERE name LIKE '%Pa??o%';
UPDATE assets SET name = replace(name, 'M??dulo', 'Módulo') WHERE name LIKE '%M??dulo%';
UPDATE assets SET name = replace(name, 'C??mputo', 'Cómputo') WHERE name LIKE '%C??mputo%';
UPDATE assets SET name = replace(name, 'Port??til', 'Portátil') WHERE name LIKE '%Port??til%';
UPDATE assets SET name = replace(name, 'Met??lico', 'Metálico') WHERE name LIKE '%Met??lico%';
UPDATE assets SET name = replace(name, 'Multiprop??sito', 'Multipropósito') WHERE name LIKE '%Multiprop??sito%';
UPDATE assets SET name = replace(name, '??ptica', 'Óptica') WHERE name LIKE '%??ptica%';
UPDATE assets SET name = replace(name, 'Tajal??piz', 'Tajalápiz') WHERE name LIKE '%Tajal??piz%';
UPDATE assets SET name = replace(name, 'El??ctrico', 'Eléctrico') WHERE name LIKE '%El??ctrico%';
UPDATE assets SET name = replace(name, 'Extensi??n', 'Extensión') WHERE name LIKE '%Extensi??n%';
UPDATE assets SET name = replace(name, 'Monof??sico', 'Monofásico') WHERE name LIKE '%Monof??sico%';
UPDATE assets SET name = replace(name, 'Telef??nico', 'Telefónico') WHERE name LIKE '%Telef??nico%';
UPDATE assets SET name = replace(name, 'Trif??sico', 'Trifásico') WHERE name LIKE '%Trif??sico%';
UPDATE assets SET name = replace(name, 'Bif??sica', 'Bifásica') WHERE name LIKE '%Bif??sica%';
UPDATE assets SET name = replace(name, 'L??ser', 'Láser') WHERE name LIKE '%L??ser%';
UPDATE assets SET name = replace(name, 'Certificaci??n', 'Certificación') WHERE name LIKE '%Certificaci??n%';

-- ---------------------------------------------------------------------------
-- assets.specifications
-- ---------------------------------------------------------------------------
UPDATE assets SET specifications = replace(specifications, 'Tel??fono', 'Teléfono') WHERE specifications LIKE '%Tel??fono%';
UPDATE assets SET specifications = replace(specifications, 'C??mara', 'Cámara') WHERE specifications LIKE '%C??mara%';
UPDATE assets SET specifications = replace(specifications, 'Botiqu??n', 'Botiquín') WHERE specifications LIKE '%Botiqu??n%';
UPDATE assets SET specifications = replace(specifications, 'pa??o', 'paño') WHERE specifications LIKE '%pa??o%';
UPDATE assets SET specifications = replace(specifications, 'M??dulo', 'Módulo') WHERE specifications LIKE '%M??dulo%';
UPDATE assets SET specifications = replace(specifications, 'c??mputo', 'cómputo') WHERE specifications LIKE '%c??mputo%';
UPDATE assets SET specifications = replace(specifications, 'Port??til', 'Portátil') WHERE specifications LIKE '%Port??til%';
UPDATE assets SET specifications = replace(specifications, 'met??lica', 'metálica') WHERE specifications LIKE '%met??lica%';
UPDATE assets SET specifications = replace(specifications, 'met??lico', 'metálico') WHERE specifications LIKE '%met??lico%';
UPDATE assets SET specifications = replace(specifications, 'multiprop??sito', 'multipropósito') WHERE specifications LIKE '%multiprop??sito%';
UPDATE assets SET specifications = replace(specifications, '??ptico', 'óptico') WHERE specifications LIKE '%??ptico%';
UPDATE assets SET specifications = replace(specifications, '??ptica', 'óptica') WHERE specifications LIKE '%??ptica%';
UPDATE assets SET specifications = replace(specifications, 'Reposici??n', 'Reposición') WHERE specifications LIKE '%Reposici??n%';
UPDATE assets SET specifications = replace(specifications, 'c??digo', 'código') WHERE specifications LIKE '%c??digo%';
UPDATE assets SET specifications = replace(specifications, 'l??mina', 'lámina') WHERE specifications LIKE '%l??mina%';
UPDATE assets SET specifications = replace(specifications, 'u??a', 'uña') WHERE specifications LIKE '%u??a%';
UPDATE assets SET specifications = replace(specifications, 'electrost??tica', 'electrostática') WHERE specifications LIKE '%electrost??tica%';
UPDATE assets SET specifications = replace(specifications, 'art??culos', 'artículos') WHERE specifications LIKE '%art??culos%';
UPDATE assets SET specifications = replace(specifications, 'tecnolog??a', 'tecnología') WHERE specifications LIKE '%tecnolog??a%';
UPDATE assets SET specifications = replace(specifications, 'seg??n', 'según') WHERE specifications LIKE '%seg??n%';
UPDATE assets SET specifications = replace(specifications, 'n??cleos', 'núcleos') WHERE specifications LIKE '%n??cleos%';
UPDATE assets SET specifications = replace(specifications, 'garant??a', 'garantía') WHERE specifications LIKE '%garant??a%';
UPDATE assets SET specifications = replace(specifications, 'a??os', 'años') WHERE specifications LIKE '%a??os%';
UPDATE assets SET specifications = replace(specifications, 'instalaci??n', 'instalación') WHERE specifications LIKE '%instalaci??n%';
UPDATE assets SET specifications = replace(specifications, 'extensi??n', 'extensión') WHERE specifications LIKE '%extensi??n%';
UPDATE assets SET specifications = replace(specifications, 's??tano', 'sótano') WHERE specifications LIKE '%s??tano%';
UPDATE assets SET specifications = replace(specifications, 'monof??sico', 'monofásico') WHERE specifications LIKE '%monof??sico%';
UPDATE assets SET specifications = replace(specifications, 'trif??sico', 'trifásico') WHERE specifications LIKE '%trif??sico%';
UPDATE assets SET specifications = replace(specifications, 'bif??sica', 'bifásica') WHERE specifications LIKE '%bif??sica%';
UPDATE assets SET specifications = replace(specifications, 'ingenier??a', 'ingeniería') WHERE specifications LIKE '%ingenier??a%';
UPDATE assets SET specifications = replace(specifications, 'l??ser', 'láser') WHERE specifications LIKE '%l??ser%';
UPDATE assets SET specifications = replace(specifications, 'm??nima', 'mínima') WHERE specifications LIKE '%m??nima%';
UPDATE assets SET specifications = replace(specifications, 'p??ginas', 'páginas') WHERE specifications LIKE '%p??ginas%';
UPDATE assets SET specifications = replace(specifications, 'certificaci??n', 'certificación') WHERE specifications LIKE '%certificaci??n%';
UPDATE assets SET specifications = replace(specifications, 'est??ndar', 'estándar') WHERE specifications LIKE '%est??ndar%';
UPDATE assets SET specifications = replace(specifications, 'm??ximo', 'máximo') WHERE specifications LIKE '%m??ximo%';
UPDATE assets SET specifications = replace(specifications, 'Tajal??piz', 'Tajalápiz') WHERE specifications LIKE '%Tajal??piz%';
UPDATE assets SET specifications = replace(specifications, 'el??ctrico', 'eléctrico') WHERE specifications LIKE '%el??ctrico%';
UPDATE assets SET specifications = replace(specifications, 'Telef??nico', 'Telefónico') WHERE specifications LIKE '%Telef??nico%';

-- El símbolo de "número" también quedó corrupto como "N??" (N + '?' + '?').
-- Se repone al final para no interferir con los reemplazos de palabras previos.
UPDATE assets SET specifications = replace(specifications, 'N??', 'N°') WHERE specifications LIKE '%N??%';

COMMIT;

-- ---------------------------------------------------------------------------
-- Verificación: no debería quedar ningún '?' huérfano en las columnas
-- afectadas. Si esta consulta devuelve filas, hay un fragmento nuevo no
-- cubierto por el diccionario anterior y debe agregarse manualmente.
-- ---------------------------------------------------------------------------
SELECT 'areas.name' AS columna, name AS valor FROM areas WHERE name LIKE '%?%'
UNION ALL
SELECT 'areas.description', description FROM areas WHERE description LIKE '%?%'
UNION ALL
SELECT 'areas.location', location FROM areas WHERE location LIKE '%?%'
UNION ALL
SELECT 'asset_types.name', name FROM asset_types WHERE name LIKE '%?%'
UNION ALL
SELECT 'asset_types.description', description FROM asset_types WHERE description LIKE '%?%'
UNION ALL
SELECT 'assets.name', name FROM assets WHERE name LIKE '%?%'
UNION ALL
SELECT 'assets.specifications', specifications FROM assets WHERE specifications LIKE '%?%';
