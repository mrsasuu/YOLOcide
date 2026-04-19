// History.jsx — history list + history detail screens.
// History entries have shape: { id, winner: {label, color}, items: [{label, color}], ts: ms }

function formatRelativeTime(ts) {
  const diff = Date.now() - ts;
  const m = Math.floor(diff / 60000);
  if (m < 1) return 'Just now';
  if (m < 60) return m + 'm ago';
  const h = Math.floor(m / 60);
  if (h < 24) return h + 'h ago';
  const d = Math.floor(h / 24);
  if (d < 7) return d + 'd ago';
  const date = new Date(ts);
  return date.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
}

function formatFullTime(ts) {
  const d = new Date(ts);
  return d.toLocaleDateString(undefined, {
    weekday: 'long', month: 'long', day: 'numeric'
  }) + ' · ' + d.toLocaleTimeString(undefined, {
    hour: 'numeric', minute: '2-digit'
  });
}

// ─── History list screen ─────────────────────────────────────────────────
function HistoryListScreen({ history = [], onBack, onOpen, onClear, dark = false }) {
  return (
    <div style={{
      position: 'relative', width: '100%', height: '100%',
      background: dark ? '#3a3d4a' : '#f4f4f7',
      color: dark ? '#f2f2f7' : '#1c1c1e',
      display: 'flex', flexDirection: 'column',
      paddingTop: 54, overflow: 'hidden',
    }}>
      <BackHeader
        title="History"
        onBack={onBack}
        dark={dark}
        right={history.length > 0 ? (
          <button onClick={onClear} style={{
            background: 'transparent', border: 0, cursor: 'pointer',
            color: '#6c5ce7', padding: '10px 8px',
            font: '500 15px/20px -apple-system, "SF Pro Text", Inter, sans-serif',
          }}>Clear</button>
        ) : null}
      />

      <div style={{
        padding: '2px 20px 0',
        font: '500 13px/1 -apple-system, "SF Pro Text", Inter, sans-serif',
        color: dark ? '#98989f' : '#8e8e93', letterSpacing: '0.04em',
        textTransform: 'uppercase', marginBottom: 10,
      }}>
        {history.length} {history.length === 1 ? 'spin' : 'spins'}
      </div>

      <div style={{
        flex: 1, overflowY: 'auto', padding: '0 20px 20px',
        display: 'flex', flexDirection: 'column', gap: 10,
      }}>
        {history.length === 0 && (
          <div style={{
            textAlign: 'center', padding: '80px 20px 40px',
            color: dark ? '#98989f' : '#8e8e93',
          }}>
            <div style={{
              width: 56, height: 56, margin: '0 auto 14px',
              borderRadius: '50%', display: 'grid', placeItems: 'center',
              background: dark ? 'rgba(255,255,255,0.06)' : 'rgba(108,92,231,0.08)',
              color: '#6c5ce7',
            }}>
              <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="12" cy="12" r="9"/>
                <path d="M12 7v5l3 2"/>
              </svg>
            </div>
            <div style={{
              font: '600 17px/22px -apple-system, "SF Pro Display", Inter, sans-serif',
              color: dark ? '#f2f2f7' : '#1c1c1e', marginBottom: 6,
            }}>No decisions yet</div>
            <div style={{ font: '500 14px/20px -apple-system, "SF Pro Text", Inter, sans-serif' }}>
              Spin the wheel to start building your history.
            </div>
          </div>
        )}

        {history.map(entry => (
          <button key={entry.id}
            onClick={() => onOpen(entry)}
            style={{
              background: dark ? 'rgba(255,255,255,0.06)' : '#fff',
              border: 0, borderRadius: 16, padding: '14px 14px',
              boxShadow: dark ? 'none' : '0 1px 3px rgba(30,24,70,0.04)',
              display: 'flex', alignItems: 'center', gap: 14,
              cursor: 'pointer', textAlign: 'left', width: '100%',
              color: 'inherit',
            }}>
            <div style={{
              width: 40, height: 40, borderRadius: 12,
              background: entry.winner.color,
              boxShadow: 'inset 0 0 0 2px rgba(255,255,255,0.6)',
              display: 'grid', placeItems: 'center', flexShrink: 0,
            }}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1c1c1e"
                strokeWidth="2.25" strokeLinecap="round" strokeLinejoin="round"
                style={{ opacity: 0.55 }}>
                <path d="M5 12l5 5L20 7"/>
              </svg>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{
                font: '600 16px/20px -apple-system, "SF Pro Display", Inter, sans-serif',
                letterSpacing: '-0.01em',
                color: dark ? '#f2f2f7' : '#1c1c1e',
                marginBottom: 3,
                overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
              }}>{entry.winner.label}</div>
              <div style={{
                font: '500 13px/18px -apple-system, "SF Pro Text", Inter, sans-serif',
                color: dark ? '#98989f' : '#8e8e93',
              }}>
                {entry.items.length} options · {formatRelativeTime(entry.ts)}
              </div>
            </div>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
              strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
              style={{ color: dark ? '#5a5a62' : '#c7c7cc', flexShrink: 0 }}>
              <path d="m9 18 6-6-6-6"/>
            </svg>
          </button>
        ))}
      </div>
    </div>
  );
}

// ─── History detail screen ───────────────────────────────────────────────
function HistoryDetailScreen({ entry, onBack, dark = false }) {
  if (!entry) return null;
  return (
    <div style={{
      position: 'relative', width: '100%', height: '100%',
      background: dark ? '#3a3d4a' : '#f4f4f7',
      color: dark ? '#f2f2f7' : '#1c1c1e',
      display: 'flex', flexDirection: 'column',
      paddingTop: 54, overflow: 'hidden',
    }}>
      <BackHeader title="Spin details" onBack={onBack} dark={dark}/>

      <div style={{ flex: 1, overflowY: 'auto', padding: '6px 20px 28px' }}>
        {/* Winner card */}
        <div style={{
          background: dark ? 'rgba(255,255,255,0.06)' : '#fff',
          borderRadius: 24, padding: '24px 20px 22px',
          textAlign: 'center', marginBottom: 18,
          boxShadow: dark ? 'none' : '0 1px 3px rgba(30,24,70,0.04)',
        }}>
          <div style={{
            font: '500 12px/1 -apple-system, "SF Pro Text", Inter, sans-serif',
            color: dark ? '#98989f' : '#8e8e93', letterSpacing: '0.1em',
            textTransform: 'uppercase', marginBottom: 12,
          }}>Fate chose</div>
          <div style={{
            width: 60, height: 60, borderRadius: '50%', background: entry.winner.color,
            margin: '0 auto 14px',
            boxShadow: 'inset 0 0 0 3px rgba(255,255,255,0.65), 0 8px 18px rgba(60,40,140,0.14)',
          }}/>
          <div style={{
            font: '800 28px/34px -apple-system, "SF Pro Display", Inter, sans-serif',
            letterSpacing: '-0.025em', color: dark ? '#f2f2f7' : '#1c1c1e',
            marginBottom: 8, wordBreak: 'break-word',
          }}>{entry.winner.label}</div>
          <div style={{
            font: '500 14px/18px -apple-system, "SF Pro Text", Inter, sans-serif',
            color: dark ? '#98989f' : '#8e8e93',
          }}>{formatFullTime(entry.ts)}</div>
        </div>

        {/* Items list */}
        <div style={{
          font: '500 12px/1 -apple-system, "SF Pro Text", Inter, sans-serif',
          color: dark ? '#98989f' : '#8e8e93', letterSpacing: '0.06em',
          textTransform: 'uppercase', marginBottom: 10, paddingLeft: 4,
        }}>
          On the wheel · {entry.items.length}
        </div>
        <div style={{
          background: dark ? 'rgba(255,255,255,0.06)' : '#fff',
          borderRadius: 18, overflow: 'hidden',
          boxShadow: dark ? 'none' : '0 1px 3px rgba(30,24,70,0.04)',
        }}>
          {entry.items.map((item, i) => {
            const isWinner = item.label === entry.winner.label;
            return (
              <div key={i} style={{
                display: 'flex', alignItems: 'center', gap: 12,
                padding: '13px 16px',
                borderBottom: i < entry.items.length - 1
                  ? (dark ? '1px solid rgba(255,255,255,0.06)' : '1px solid rgba(60,60,67,0.08)')
                  : 'none',
              }}>
                <div style={{
                  width: 24, height: 24, borderRadius: 8, background: item.color,
                  boxShadow: 'inset 0 0 0 1.5px rgba(255,255,255,0.55)',
                  flexShrink: 0,
                }}/>
                <div style={{
                  flex: 1,
                  font: '500 16px/20px -apple-system, "SF Pro Text", Inter, sans-serif',
                  color: dark ? '#f2f2f7' : '#1c1c1e',
                }}>{item.label}</div>
                {isWinner && (
                  <div style={{
                    font: '600 11px/1 -apple-system, "SF Pro Text", Inter, sans-serif',
                    color: '#6c5ce7', letterSpacing: '0.06em', textTransform: 'uppercase',
                    background: dark ? 'rgba(108,92,231,0.18)' : 'rgba(108,92,231,0.12)',
                    padding: '5px 8px', borderRadius: 6,
                  }}>Winner</div>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

window.HistoryListScreen = HistoryListScreen;
window.HistoryDetailScreen = HistoryDetailScreen;
