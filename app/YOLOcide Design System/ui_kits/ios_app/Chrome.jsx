// Chrome.jsx — app header, primary button, toggle.

function AppHeader({ title = 'YOLOcide', onAdd, onHistory, dark = false }) {
  const iconBtnStyle = {
    width: 44, height: 44, borderRadius: 999, border: 0, cursor: 'pointer',
    background: dark ? 'rgba(255,255,255,0.10)' : 'rgba(255,255,255,0.72)',
    WebkitBackdropFilter: 'blur(18px) saturate(1.3)',
    backdropFilter: 'blur(18px) saturate(1.3)',
    boxShadow: dark
      ? 'inset 0 0 0 1px rgba(255,255,255,0.12)'
      : 'inset 0 0 0 1px rgba(0,0,0,0.05), 0 2px 6px rgba(30,24,70,0.06)',
    display: 'grid', placeItems: 'center', color: dark ? '#f2f2f7' : '#1c1c1e',
  };
  return (
    <div style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '8px 20px 6px',
    }}>
      <div style={{
        fontFamily: '-apple-system, "SF Pro Display", Inter, sans-serif',
        fontWeight: 800, fontSize: 34, letterSpacing: '-0.035em',
        color: dark ? '#f2f2f7' : '#1c1c1e',
      }}>
        YOLO<span style={{ color: '#6c5ce7' }}>cide</span>
      </div>
      <div style={{ display: 'flex', gap: 8 }}>
        {onHistory && (
          <button onClick={onHistory} aria-label="History" style={iconBtnStyle}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
              strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="12" cy="12" r="9"/>
              <path d="M12 7v5l3 2"/>
            </svg>
          </button>
        )}
        {onAdd && (
          <button onClick={onAdd} aria-label="Add option" style={iconBtnStyle}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor"
              strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M5 12h14"/><path d="M12 5v14"/>
            </svg>
          </button>
        )}
      </div>
    </div>
  );
}

// Back header for secondary screens
function BackHeader({ title, onBack, dark = false, right = null }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '8px 12px 6px',
    }}>
      <button onClick={onBack} aria-label="Back" style={{
        display: 'flex', alignItems: 'center', gap: 2,
        background: 'transparent', border: 0, cursor: 'pointer',
        color: '#6c5ce7', padding: '10px 8px',
        font: '500 17px/22px -apple-system, "SF Pro Text", Inter, sans-serif',
      }}>
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor"
          strokeWidth="2.25" strokeLinecap="round" strokeLinejoin="round">
          <path d="m15 18-6-6 6-6"/>
        </svg>
        <span>Back</span>
      </button>
      <div style={{
        font: '700 17px/22px -apple-system, "SF Pro Display", Inter, sans-serif',
        letterSpacing: '-0.01em',
        color: dark ? '#f2f2f7' : '#1c1c1e',
      }}>{title}</div>
      <div style={{ minWidth: 60, textAlign: 'right' }}>{right}</div>
    </div>
  );
}

// iOS-style toggle switch
function Switch({ on, onChange, dark = false }) {
  return (
    <button
      onClick={() => onChange(!on)}
      role="switch"
      aria-checked={on}
      style={{
        width: 48, height: 28, borderRadius: 999, border: 0, cursor: 'pointer',
        background: on ? '#6c5ce7' : (dark ? 'rgba(255,255,255,0.14)' : '#e5e5ea'),
        transition: 'background 220ms ease',
        position: 'relative', padding: 0, flexShrink: 0,
      }}
    >
      <span style={{
        position: 'absolute', top: 2, left: on ? 22 : 2,
        width: 24, height: 24, borderRadius: '50%', background: '#fff',
        boxShadow: '0 1px 3px rgba(0,0,0,0.15), 0 2px 6px rgba(0,0,0,0.08)',
        transition: 'left 220ms cubic-bezier(0.34, 1.56, 0.64, 1)',
      }}/>
    </button>
  );
}

function PrimaryButton({ children, onClick, disabled, dark = false, style }) {
  const [pressed, setPressed] = React.useState(false);
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      onPointerDown={() => setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      style={{
        width: '100%', padding: '16px 22px', borderRadius: 999, border: 0,
        background: '#6c5ce7', color: '#fff',
        font: '600 17px/22px -apple-system, "SF Pro Text", Inter, sans-serif',
        cursor: disabled ? 'not-allowed' : 'pointer',
        opacity: disabled ? 0.4 : 1,
        boxShadow: '0 8px 20px rgba(108,92,231,0.28), inset 0 1px 0 rgba(255,255,255,0.22)',
        transform: pressed ? 'scale(0.97)' : 'scale(1)',
        transition: 'transform 180ms cubic-bezier(0.34, 1.56, 0.64, 1)',
        ...style,
      }}>
      {children}
    </button>
  );
}

function ToggleButton({ open, onClick, dark = false }) {
  return (
    <button onClick={onClick}
      style={{
        background: 'transparent', border: 0, cursor: 'pointer',
        font: '500 15px/20px -apple-system, "SF Pro Text", Inter, sans-serif',
        color: dark ? '#c7c7cc' : '#48484a',
        display: 'inline-flex', alignItems: 'center', gap: 6, padding: '10px 14px',
      }}>
      {open ? 'Hide options' : 'Show options'}
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
        strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"
        style={{
          transform: open ? 'rotate(180deg)' : 'rotate(0deg)',
          transition: 'transform 260ms cubic-bezier(0.34, 1.56, 0.64, 1)'
        }}>
        <path d="m6 9 6 6 6-6"/>
      </svg>
    </button>
  );
}

function ResultBanner({ result, onDismiss, dark = false }) {
  if (!result) return null;
  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 40, display: 'grid', placeItems: 'center',
      background: dark ? 'rgba(0,0,0,0.45)' : 'rgba(20,20,40,0.25)',
      WebkitBackdropFilter: 'blur(8px)', backdropFilter: 'blur(8px)',
      padding: 20,
      animation: 'fade-in 260ms cubic-bezier(0.22,1,0.36,1)',
    }}
    onClick={onDismiss}
    >
      <div style={{
        background: dark ? '#454856' : '#fff', borderRadius: 28, padding: '28px 24px',
        width: '100%', maxWidth: 340, textAlign: 'center',
        boxShadow: '0 28px 60px rgba(60,40,140,0.25)',
        animation: 'spring-in 420ms cubic-bezier(0.34, 1.56, 0.64, 1)',
      }}>
        <div style={{
          font: '500 13px/1 -apple-system, "SF Pro Text", Inter, sans-serif',
          color: dark ? '#98989f' : '#8e8e93', letterSpacing: '0.08em',
          textTransform: 'uppercase', marginBottom: 10,
        }}>Fate has spoken</div>
        <div style={{
          font: '800 32px/38px -apple-system, "SF Pro Display", Inter, sans-serif',
          letterSpacing: '-0.03em', color: dark ? '#f2f2f7' : '#1c1c1e',
          marginBottom: 18, wordBreak: 'break-word',
        }}>{result.label}</div>
        <div style={{
          width: 48, height: 48, borderRadius: 999, background: result.color,
          margin: '0 auto 18px',
          boxShadow: 'inset 0 0 0 2px rgba(255,255,255,0.6)',
        }}/>
        <PrimaryButton onClick={onDismiss} dark={dark}>Sounds good</PrimaryButton>
      </div>
      <style>{`
        @keyframes fade-in { from { opacity: 0 } to { opacity: 1 } }
        @keyframes spring-in {
          0% { transform: scale(0.85); opacity: 0; }
          100% { transform: scale(1); opacity: 1; }
        }
      `}</style>
    </div>
  );
}

function AddSheet({ open, onAdd, onClose, dark = false }) {
  const [value, setValue] = React.useState('');
  React.useEffect(() => { if (open) setValue(''); }, [open]);
  if (!open) return null;
  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 45, display: 'flex', alignItems: 'flex-end',
      background: 'rgba(20,20,40,0.35)', WebkitBackdropFilter: 'blur(8px)', backdropFilter: 'blur(8px)',
      animation: 'fade-in 220ms ease-out',
    }}
    onClick={onClose}
    >
      <div
        onClick={e => e.stopPropagation()}
        style={{
          width: '100%', background: dark ? '#454856' : '#fff',
          borderTopLeftRadius: 28, borderTopRightRadius: 28,
          padding: '14px 20px 28px',
          animation: 'slide-up 340ms cubic-bezier(0.34, 1.56, 0.64, 1)',
        }}>
        <div style={{
          width: 36, height: 5, borderRadius: 3, background: dark ? 'rgba(255,255,255,0.2)' : 'rgba(0,0,0,0.15)',
          margin: '0 auto 14px',
        }}/>
        <div style={{
          font: '700 22px/28px -apple-system, "SF Pro Display", Inter, sans-serif',
          letterSpacing: '-0.02em', color: dark ? '#f2f2f7' : '#1c1c1e', marginBottom: 14,
        }}>Add an option</div>
        <input
          autoFocus
          value={value}
          onChange={e => setValue(e.target.value)}
          placeholder="e.g. Pizza"
          onKeyDown={e => { if (e.key === 'Enter' && value.trim()) onAdd(value.trim()); }}
          style={{
            width: '100%', padding: '14px 16px', borderRadius: 14, border: 0, outline: 'none',
            background: dark ? 'rgba(255,255,255,0.10)' : '#f4f4f7',
            boxShadow: dark ? 'inset 0 0 0 1px rgba(255,255,255,0.12)' : 'inset 0 0 0 1px rgba(0,0,0,0.06)',
            color: dark ? '#f2f2f7' : '#1c1c1e',
            font: '500 17px/22px -apple-system, "SF Pro Text", Inter, sans-serif',
            marginBottom: 14, boxSizing: 'border-box',
          }}
        />
        <PrimaryButton
          disabled={!value.trim()}
          onClick={() => value.trim() && onAdd(value.trim())}
          dark={dark}
        >Add to wheel</PrimaryButton>
      </div>
      <style>{`
        @keyframes slide-up { from { transform: translateY(100%); } to { transform: translateY(0); } }
      `}</style>
    </div>
  );
}

Object.assign(window, { AppHeader, BackHeader, Switch, PrimaryButton, ToggleButton, ResultBanner, AddSheet });
