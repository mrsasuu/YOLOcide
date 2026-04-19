// OptionRow.jsx — a frosted pill row showing an option's label + color dot.
// Tapping the dot opens a color picker (palette of the 6 brand pastels).

function OptionRow({ option, onColorChange, onDelete, dark = false }) {
  const [picking, setPicking] = React.useState(false);
  const palette = dark ? window.WHEEL_PASTELS_DARK : window.WHEEL_PASTELS;

  return (
    <div style={{
      position: 'relative',
      display: 'grid', gridTemplateColumns: '1fr auto', alignItems: 'center',
      padding: '14px 16px 14px 18px', borderRadius: 14,
      background: dark ? 'rgba(255,255,255,0.10)' : 'rgba(255,255,255,0.72)',
      WebkitBackdropFilter: 'blur(20px) saturate(1.4)',
      backdropFilter: 'blur(20px) saturate(1.4)',
      boxShadow: dark
        ? 'inset 0 0 0 1px rgba(255,255,255,0.12)'
        : 'inset 0 0 0 1px rgba(0,0,0,0.06), 0 1px 2px rgba(16,16,32,0.04)',
      font: '500 17px/22px -apple-system, "SF Pro Text", Inter, sans-serif',
      color: dark ? '#f2f2f7' : '#1c1c1e',
    }}>
      <span style={{
        whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
        paddingRight: 10,
      }}>{option.label}</span>

      <button
        onClick={() => setPicking(p => !p)}
        aria-label="Change color"
        style={{
          width: 22, height: 22, borderRadius: 999, border: 0, padding: 0, cursor: 'pointer',
          background: option.color,
          boxShadow: dark
            ? 'inset 0 0 0 1px rgba(255,255,255,0.2)'
            : 'inset 0 0 0 1px rgba(0,0,0,0.08)',
        }}
      />

      {picking && (
        <div style={{
          position: 'absolute', right: 10, top: 'calc(100% + 6px)', zIndex: 20,
          display: 'flex', gap: 8, padding: 10, borderRadius: 14,
          background: dark ? 'rgba(50,52,62,0.92)' : 'rgba(255,255,255,0.92)',
          WebkitBackdropFilter: 'blur(22px) saturate(1.4)',
          backdropFilter: 'blur(22px) saturate(1.4)',
          boxShadow: '0 20px 40px rgba(30,24,70,0.20), inset 0 0 0 1px rgba(0,0,0,0.05)',
        }}>
          {palette.slice(0, 6).map((c, i) => (
            <button key={i}
              onClick={() => { onColorChange(c); setPicking(false); }}
              style={{
                width: 26, height: 26, borderRadius: 999, border: 0, cursor: 'pointer',
                background: c,
                boxShadow: option.color === c
                  ? '0 0 0 2px #6c5ce7, inset 0 0 0 2px #fff'
                  : 'inset 0 0 0 1px rgba(0,0,0,0.08)',
              }}
            />
          ))}
          {onDelete && (
            <button onClick={onDelete} aria-label="Delete"
              style={{
                width: 26, height: 26, borderRadius: 999, border: 0, cursor: 'pointer',
                background: 'transparent', display: 'grid', placeItems: 'center',
                color: dark ? '#f2f2f7' : '#48484a',
              }}>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M3 6h18"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
              </svg>
            </button>
          )}
        </div>
      )}
    </div>
  );
}

window.OptionRow = OptionRow;
