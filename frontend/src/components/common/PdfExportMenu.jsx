import { useState } from 'react';
import { Button, IconButton, Menu, MenuItem, ListItemText, Tooltip } from '@mui/material';
import PictureAsPdfIcon from '@mui/icons-material/PictureAsPdf';
import ArrowDropDownIcon from '@mui/icons-material/ArrowDropDown';

// Botón (o ícono) con menú desplegable para elegir entre variantes de exportación PDF.
// options: [{ label, description?, onClick, disabled? }]
export default function PdfExportMenu({
  options,
  variant = 'button',
  label = 'Exportar PDF',
  disabled = false,
  buttonProps = {},
}) {
  const [anchorEl, setAnchorEl] = useState(null);
  const open = Boolean(anchorEl);

  const handleSelect = (option) => {
    setAnchorEl(null);
    option.onClick();
  };

  const menu = (
    <Menu anchorEl={anchorEl} open={open} onClose={() => setAnchorEl(null)}>
      {options.map((opt) => (
        <MenuItem key={opt.label} onClick={() => handleSelect(opt)} disabled={opt.disabled}>
          <ListItemText primary={opt.label} secondary={opt.description} />
        </MenuItem>
      ))}
    </Menu>
  );

  if (variant === 'icon') {
    return (
      <>
        <Tooltip title={label}>
          <span>
            <IconButton size="small" onClick={(e) => setAnchorEl(e.currentTarget)} disabled={disabled}>
              <PictureAsPdfIcon fontSize="small" />
            </IconButton>
          </span>
        </Tooltip>
        {menu}
      </>
    );
  }

  return (
    <>
      <Button
        variant="outlined"
        color="secondary"
        startIcon={<PictureAsPdfIcon />}
        endIcon={<ArrowDropDownIcon />}
        onClick={(e) => setAnchorEl(e.currentTarget)}
        disabled={disabled}
        {...buttonProps}
      >
        {label}
      </Button>
      {menu}
    </>
  );
}
