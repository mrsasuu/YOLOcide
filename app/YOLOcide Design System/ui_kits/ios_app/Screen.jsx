// Screen.jsx — the full YOLOcide screen. Composes header + wheel + option list + CTA.

const { useState, useRef, useEffect } = React;

function YolocideScreen({ dark = false }) {
  const [options, setOptions] = useState([
    { id: 1, label: 'Tacos',   color: '#ffd4b8' },
    { id: 2, label: 'Sushi',   color: '#bfeed6' },
    { id: 3, label: 'Pizza',   color: '#ffc1d0' },
    { id: 4, label: 'Ramen',   color: '#c8bfff' },
    { id: 5, label: 'Salad',   color: '#bfdcff' },
    { id: 6, label: 'Call it off', color: '#d8b8ff' },
  ]);
  const [listOpen, setListOpen] = useState(false);
  const [result, setResult] = useState(null);
  const [adding, setAdding] = useState(false);
  const wheelRef = useRef(null);

  const palette = dark ? window.WHEEL_PASTELS_DARK : window.WHEEL_PASTELS;

  const addOption = (label) => {
    setOptions(prev => [...prev, {
      id: Date.now(), label,
      color: palette[prev.length % palette.length],
    }]);
    setAdding(false);
  };
  const updateColor = (id, color) =>
    setOptions(prev => prev.map(o => o.id === id ? { ...o, color } : o));
  const deleteOption = (id) =>
    setOptions(prev => prev.filter(o => o.id !== id));

  const wheelSize = listOpen ? 180 : 260;

  return (
    <div style={{
      position: 'relative', width: '100%', height: '100%',
      background: dark ? '#3a3d4a' : '#f4f4f7',
      color: dark ? '#f2f2f7' : '#1c1c1e',
      overflow: 'hidden',
      display: 'flex', flexDirection: 'column',
      minHeight: 0,
      paddingTop: 54,
    }}>
      <AppHeader dark={dark} onAdd={() => setAdding(true)} />

      {/* wheel stage — flex-shrink so CTA below is always visible */}
      <div style={{
        display: 'flex', flexDirection: 'column', alignItems: 'center',
        paddingTop: listOpen ? 8 : 16,
        flexShrink: 0,
        transition: 'padding-top 420ms cubic-bezier(0.34, 1.56, 0.64, 1)',
      }}>
        <div style={{
          width: wheelSize, height: wheelSize + 14,
          transition: 'width 420ms cubic-bezier(0.34, 1.56, 0.64, 1), height 420ms cubic-bezier(0.34, 1.56, 0.64, 1)',
          display: 'grid', placeItems: 'center',
        }}>
          <Wheel
            ref={wheelRef}
            options={options}
            size={wheelSize}
            dark={dark}
            onSpinEnd={(r) => setResult(r)}
          />
        </div>
        <div style={{ marginTop: 10 }}>
          <ToggleButton open={listOpen} onClick={() => setListOpen(o => !o)} dark={dark} />
        </div>
      </div>

      {/* option list */}
      {listOpen && (
        <div style={{
          flex: 1, padding: '6px 20px 20px',
          overflowY: 'auto',
          display: 'flex', flexDirection: 'column', gap: 10,
          animation: 'list-in 340ms cubic-bezier(0.34, 1.56, 0.64, 1)',
        }}>
          {options.length === 0 && (
            <div style={{
              textAlign: 'center', padding: '40px 20px', color: dark ? '#98989f' : '#8e8e93',
              font: '500 15px/20px -apple-system, "SF Pro Text", Inter, sans-serif',
            }}>
              Nothing to decide yet. Add an option.
            </div>
          )}
          {options.map(opt => (
            <OptionRow key={opt.id} option={opt} dark={dark}
              onColorChange={(c) => updateColor(opt.id, c)}
              onDelete={() => deleteOption(opt.id)}
            />
          ))}
        </div>
      )}

      {/* primary CTA — only when list closed */}
      {!listOpen && (
        <div style={{
          marginTop: 'auto', padding: '20px 20px 34px',
          animation: 'cta-in 340ms cubic-bezier(0.34, 1.56, 0.64, 1)',
        }}>
          <PrimaryButton
            dark={dark}
            disabled={options.length < 2}
            onClick={() => wheelRef.current?.spin()}
          >Spin my fate</PrimaryButton>
        </div>
      )}

      <ResultBanner result={result} onDismiss={() => setResult(null)} dark={dark} />
      <AddSheet open={adding} onAdd={addOption} onClose={() => setAdding(false)} dark={dark} />

      <style>{`
        @keyframes list-in {
          from { opacity: 0; transform: translateY(14px); }
          to { opacity: 1; transform: translateY(0); }
        }
        @keyframes cta-in {
          from { opacity: 0; transform: translateY(14px); }
          to { opacity: 1; transform: translateY(0); }
        }
      `}</style>
    </div>
  );
}

window.YolocideScreen = YolocideScreen;
