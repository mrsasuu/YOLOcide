// Wheel.jsx — YOLOcide wheel, redesigned as a "hex-star" per latest direction.
// A circle contains an inscribed hexagon. Between the hexagon edges and the
// circle edge sit 6 pointed "triangle wedges" — each in a brand color.
// Background of the disc matches the app canvas (light/dark). The six wedges
// ARE the color — everything else is transparent. Center cap carries "Spin!".

const WHEEL_COLORS = [
  '#ae8cff', // violet (top)
  '#6db4f5', // sky
  '#6fd3a3', // mint
  '#ff9f70', // peach
  '#ff7f9d', // rose
  '#c47cf0', // lavender/magenta
];

// kept for OptionRow default palette compatibility
const WHEEL_PASTELS      = ['#c8bfff','#bfdcff','#bfeed6','#ffd4b8','#ffc1d0','#d8b8ff','#ffe8a8','#b8ecec'];
const WHEEL_PASTELS_DARK = [
  'rgba(200,191,255,0.75)','rgba(191,220,255,0.75)','rgba(191,238,214,0.75)','rgba(255,212,184,0.75)',
  'rgba(255,193,208,0.75)','rgba(216,184,255,0.75)','rgba(255,232,168,0.75)','rgba(184,236,236,0.75)'
];

function polar(cx, cy, r, deg) {
  const rad = (deg - 90) * Math.PI / 180;
  return { x: cx + r * Math.cos(rad), y: cy + r * Math.sin(rad) };
}

const Wheel = React.forwardRef(function Wheel({
  options, size = 320, dark = false, onSpinEnd,
}, ref) {
  const [rotation, setRotation] = React.useState(0);
  const [spinning, setSpinning] = React.useState(false);
  const uid = React.useId();

  // We always render 6 wedges — even if options.length differs, we still cycle
  // through 6 slots visually. (The product brief keeps the 6-slice motif.)
  const n = 6;
  const effective = options.slice(0, n);

  React.useImperativeHandle(ref, () => ({
    spin() {
      if (spinning || options.length === 0) return;
      setSpinning(true);
      const winnerIdx = Math.floor(Math.random() * options.length);
      // map to visual slot (0..n-1)
      const slot = winnerIdx % n;
      const targetMid = slot * (360/n) + (360/n)/2;
      const extra = 5 * 360 + (360 - targetMid);
      const base = rotation % 360;
      const next = rotation - base + extra;
      setRotation(next);
      setTimeout(() => {
        setSpinning(false);
        onSpinEnd && onSpinEnd(options[winnerIdx], winnerIdx);
      }, 3600);
    }
  }), [rotation, spinning, options]);

  const pad = 8;
  const r = size / 2 - pad;
  const cx = size / 2, cy = size / 2;

  // Point-top hexagon inscribed in the circle of radius r.
  // Vertices at angles 0° (top), 60°, 120°, 180° (bottom), 240°, 300°.
  //
  // The colored segments are the 6 CRESCENTS between each hex EDGE and the
  // corresponding arc of the circle (the regions where the circle extends
  // beyond the hexagon). Each crescent sits on ONE edge; its midpoint is
  // aligned with the edge midpoint at angles 30°, 90°, 150°, 210°, 270°, 330°.
  const hexR = r;
  const vertices = Array.from({length: n}, (_, i) => polar(cx, cy, hexR, i * 60));

  // Crescent i is between vertex i and vertex i+1.
  const wedgePath = (i) => {
    const a = vertices[i];
    const b = vertices[(i + 1) % n];
    // arc goes clockwise from a to b along the outer circle (largerArc=0, sweep=1)
    return `M ${a.x} ${a.y} A ${r} ${r} 0 0 1 ${b.x} ${b.y} Z`;
  };

  const capR = size * 0.19;

  // Label placement — along each vertex direction, between the wedge base
  // and the cap. Labels stay horizontal (counter-rotated against the wheel's
  // current rotation so they remain upright while spinning would feel off —
  // but since labels rotate with wheel, keeping horizontal here means the
  // label rotates WITH the wheel but reads upright when at rest of 0°).
  const labelR = r * 0.62;

  return (
    <div style={{ position: 'relative', width: size, height: size + 8 }}>
      {/* pointer */}
      <div style={{
        position: 'absolute', top: 0, left: '50%', transform: 'translateX(-50%)',
        zIndex: 3,
      }}>
        <svg width="18" height="14" viewBox="0 0 18 14">
          <path d="M9 13 L2 3 A 1 1 0 0 1 3 2 L15 2 A 1 1 0 0 1 16 3 Z"
            fill={dark ? '#f2f2f7' : '#1c1c1e'}/>
        </svg>
      </div>

      <div style={{
        position: 'absolute', top: 6, left: 0, width: size, height: size,
        filter: dark
          ? 'drop-shadow(0 18px 28px rgba(0,0,0,0.35)) drop-shadow(0 2px 6px rgba(0,0,0,0.25))'
          : 'drop-shadow(0 22px 32px rgba(60,40,140,0.14)) drop-shadow(0 4px 10px rgba(60,40,140,0.08))',
      }}>
        <svg
          width={size} height={size} viewBox={`0 0 ${size} ${size}`}
          style={{
            transform: `rotate(${rotation}deg)`,
            transition: spinning ? 'transform 3.6s cubic-bezier(0.16, 1, 0.3, 1)' : 'none',
            display: 'block',
          }}
        >
          <defs>
            {/* per-wedge linear gradient: slightly darker toward the tip (rim) */}

          </defs>

          {/* subtle outer ring */}
          <circle cx={cx} cy={cy} r={r}
            fill="none"
            stroke={dark ? 'rgba(255,255,255,0.08)' : 'rgba(60,40,140,0.08)'}
            strokeWidth={1}/>

          {/* hexagon outline — faint, sits just inside the crescents */}
          <path
            d={vertices.map((v, i) => (i === 0 ? `M ${v.x} ${v.y}` : `L ${v.x} ${v.y}`)).join(' ') + ' Z'}
            fill="none"
            stroke={dark ? 'rgba(255,255,255,0.06)' : 'rgba(60,40,140,0.05)'}
            strokeWidth={1}
          />

          {/* 6 colored wedges — flat, graphic */}
          {effective.map((opt, i) => {
            const base = opt.color || WHEEL_COLORS[i % WHEEL_COLORS.length];
            return (
              <path key={i}
                d={wedgePath(i)}
                fill={base}
                opacity={dark ? 0.85 : 0.92}
              />
            );
          })}


        </svg>
      </div>

      {/* labels — one per hex edge, placed just inside each edge midpoint.
          Each label sits next to its corresponding colored crescent.
          Labels stay upright (outside the rotating group). */}
      <div style={{
        position: 'absolute', top: 6, left: 0, width: size, height: size,
        pointerEvents: 'none',
      }}>
        {effective.map((opt, i) => {
          // edge i is between vertex i and vertex i+1, midpoint at angle 30 + 60i
          const midAngle = 30 + i * 60;
          // label sits on the hex edge midpoint, pulled slightly inward.
          const { x, y } = polar(cx, cy, r * 0.74, midAngle);
          // hex edge is perpendicular to the radius at its midpoint, so the
          // text rotation equals midAngle (no offset) to lie parallel to the edge.
          let textAngle = midAngle;
          // normalize to -90..90 so text never reads upside-down
          if (textAngle > 90 && textAngle < 270) textAngle -= 180;
          return (
            <div key={i} style={{
              position: 'absolute',
              left: x, top: y,
              transform: `translate(-50%, -50%) rotate(${textAngle}deg)`,
              fontFamily: '-apple-system, "SF Pro Display", Inter, sans-serif',
              fontWeight: 500,
              fontSize: Math.min(12, Math.max(9, size * 0.037)),
              color: dark ? 'rgba(242,242,247,0.85)' : 'rgba(28,28,30,0.78)',
              letterSpacing: '0.01em',
              whiteSpace: 'nowrap',
            }}>
              {opt.label}
            </div>
          );
        })}
      </div>

      {/* center cap — premium glass button with gradient ring and dimensional depth */}
      <div style={{
        position: 'absolute', top: 6 + cy - capR, left: cx - capR,
        width: capR * 2, height: capR * 2, borderRadius: '50%',
        padding: 2,
        background: dark
          ? 'linear-gradient(155deg, rgba(255,255,255,0.18), rgba(108,92,231,0.25) 50%, rgba(0,0,0,0.45))'
          : 'linear-gradient(155deg, #ffffff, #d8ceff 55%, #a79bff)',
        boxShadow: dark
          ? '0 14px 30px rgba(0,0,0,0.55), 0 4px 10px rgba(0,0,0,0.35), inset 0 1px 0 rgba(255,255,255,0.10)'
          : '0 18px 34px rgba(60,40,140,0.22), 0 6px 14px rgba(60,40,140,0.10), inset 0 1px 0 rgba(255,255,255,0.9)',
        userSelect: 'none',
      }}>
        <div style={{
          width: '100%', height: '100%', borderRadius: '50%',
          background: dark
            ? 'radial-gradient(circle at 50% 30%, #3a3d4a 0%, #24262f 75%, #1a1b22 100%)'
            : 'radial-gradient(circle at 50% 28%, #ffffff 0%, #f5f2ff 70%, #ebe5ff 100%)',
          boxShadow: dark
            ? 'inset 0 1px 2px rgba(255,255,255,0.08), inset 0 -8px 18px rgba(0,0,0,0.4)'
            : 'inset 0 1px 2px rgba(255,255,255,1), inset 0 -10px 20px rgba(108,92,231,0.08)',
          display: 'grid', placeItems: 'center',
          position: 'relative',
        }}>
          <span style={{
            color: dark ? '#f2f2f7' : '#3a2d8a',
            fontFamily: '-apple-system, "SF Pro Display", Inter, sans-serif',
            fontWeight: 700,
            fontSize: Math.max(15, size * 0.075),
            letterSpacing: '-0.015em',
            textShadow: dark
              ? '0 1px 2px rgba(0,0,0,0.4)'
              : '0 1px 0 rgba(255,255,255,0.8)',
          }}>Spin!</span>
        </div>
      </div>
    </div>
  );
});

window.Wheel = Wheel;
window.WHEEL_PASTELS = WHEEL_PASTELS;
window.WHEEL_PASTELS_DARK = WHEEL_PASTELS_DARK;
