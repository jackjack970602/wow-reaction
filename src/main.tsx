import { StrictMode, useEffect, useRef, useState } from "react";
import type { CSSProperties, PointerEvent } from "react";
import { createRoot } from "react-dom/client";
import lottie from "lottie-web";
import csatImage from "../csat2x.png";
import tuiChip from "../tui-chip.svg";
import tuiChipPressed from "../tui-chip-1.svg";
import tuiChipActive from "../tui-chip-2.svg";
import heartSmileAnimation from "../heart-smile-animation.json";
import heartIcon from "../heart.svg";
import heartIcon2 from "../heart 2.svg";
import "./styles.css";

type EmojiParticle = {
  id: number;
  texture: string;
  delay: number;
  x25: number;
  y25: number;
  x50: number;
  y50: number;
  x75: number;
  y75: number;
  x100: number;
  y100: number;
  rotation25: number;
  rotation50: number;
  rotation75: number;
  rotation100: number;
  trailRotation: number;
  scale: number;
  scale25: number;
  scale50: number;
  scale75: number;
  scaleEnd: number;
  duration: number;
};

let particleId = 0;

const createEmojiBurst = () => {
  const particleBirthRate = 120;
  const particleCount = 18;
  const particleLifetime = 0.9;
  const particleLifetimeRange = 0.25;
  const particleSpeed = 160;
  const particleSpeedRange = 90;
  const particleScale = 0.42;
  const particleScaleRange = 0.04;
  const particleScaleSpeed = -0.25;
  const particleRotationSpeed = 1.2;
  const yAcceleration = 80;

  return Array.from({ length: particleCount }, (_, index) => {
    const lifetime =
      particleLifetime + (Math.random() - 0.5) * particleLifetimeRange * 2;
    const speed = particleSpeed + (Math.random() - 0.5) * particleSpeedRange * 2;
    const angle = Math.random() * Math.PI * 2;
    const velocityX = Math.cos(angle) * speed;
    const velocityY = Math.sin(angle) * speed;
    const rotationStart = (Math.random() - 0.5) * Math.PI;
    const scale = Math.max(
      0.18,
      particleScale + (Math.random() - 0.5) * particleScaleRange * 2,
    );
    const scaleEnd = Math.max(0.08, scale + particleScaleSpeed * lifetime);

    const positionAt = (progress: number) => {
      const time = lifetime * progress;

      return {
        x: velocityX * time,
        y: velocityY * time + 0.5 * yAcceleration * time * time,
        rotation: rotationStart + particleRotationSpeed * time,
      };
    };

    const p25 = positionAt(0.25);
    const p50 = positionAt(0.5);
    const p75 = positionAt(0.75);
    const p100 = positionAt(1);

    return {
      id: particleId++,
      texture: Math.random() > 0.5 ? heartIcon : heartIcon2,
      delay: (index / particleBirthRate) * 1000,
      x25: p25.x,
      y25: p25.y,
      x50: p50.x,
      y50: p50.y,
      x75: p75.x,
      y75: p75.y,
      x100: p100.x,
      y100: p100.y,
      rotation25: p25.rotation,
      rotation50: p50.rotation,
      rotation75: p75.rotation,
      rotation100: p100.rotation,
      trailRotation: angle + Math.PI,
      scale,
      scale25: scale + (scaleEnd - scale) * 0.25,
      scale50: scale + (scaleEnd - scale) * 0.5,
      scale75: scale + (scaleEnd - scale) * 0.75,
      scaleEnd,
      duration: lifetime * 1000,
    };
  });
};

function HeartSmileAnimation({ onComplete }: { onComplete: () => void }) {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current) {
      return;
    }

    const animation = lottie.loadAnimation({
      container: containerRef.current,
      renderer: "svg",
      loop: false,
      autoplay: true,
      animationData: heartSmileAnimation,
      rendererSettings: {
        preserveAspectRatio: "xMidYMid meet",
      },
    });

    animation.addEventListener("complete", onComplete);

    return () => {
      animation.removeEventListener("complete", onComplete);
      animation.destroy();
    };
  }, [onComplete]);

  return <div className="chip-smile" ref={containerRef} aria-hidden="true" />;
}

function App() {
  const [isActive, setIsActive] = useState(false);
  const [isPressed, setIsPressed] = useState(false);
  const [isSmileAnimating, setIsSmileAnimating] = useState(false);
  const [smileAnimationKey, setSmileAnimationKey] = useState(0);
  const [ripplePosition, setRipplePosition] = useState({ x: 68, y: 15 });
  const [particles, setParticles] = useState<EmojiParticle[]>([]);

  const activateChip = (event: PointerEvent<HTMLButtonElement>) => {
    const bounds = event.currentTarget.getBoundingClientRect();
    setRipplePosition({
      x: event.clientX - bounds.left,
      y: event.clientY - bounds.top,
    });
    setParticles((currentParticles) => [...currentParticles, ...createEmojiBurst()]);
    setIsSmileAnimating(true);
    setSmileAnimationKey((key) => key + 1);

    if (!isActive) {
      setIsActive(true);
    }
  };

  return (
    <main className="page-shell" aria-label="CSAT mobile prototype">
      <section className="phone-screen">
        <img className="screen-image" src={csatImage} alt="CSAT reaction interface" />
        <button
          className="tui-chip"
          type="button"
          aria-pressed={isActive}
          aria-label="Это было вау!"
          data-active={isActive}
          data-pressed={isPressed}
          data-smile-animating={isSmileAnimating}
          style={
            {
              "--ripple-x": `${ripplePosition.x}px`,
              "--ripple-y": `${ripplePosition.y}px`,
            } as CSSProperties
          }
          onPointerCancel={() => setIsPressed(false)}
          onPointerDown={() => setIsPressed(true)}
          onPointerLeave={() => setIsPressed(false)}
          onPointerUp={(event) => {
            setIsPressed(false);
            activateChip(event);
          }}
        >
          <span className="chip-visual">
            <img className="chip-state chip-state-default" src={tuiChip} alt="" />
            <img className="chip-state chip-state-pressed" src={tuiChipPressed} alt="" />
            <img className="chip-state chip-state-active" src={tuiChipActive} alt="" />
            <span className="chip-smile-cover" aria-hidden="true" />
          </span>
          {isSmileAnimating && (
            <HeartSmileAnimation
              key={smileAnimationKey}
              onComplete={() => setIsSmileAnimating(false)}
            />
          )}
          {particles.map((particle) => (
            <span
              key={particle.id}
              className="emoji-particle"
              style={
                {
                  "--particle-delay": `${particle.delay}ms`,
                  "--particle-x-25": `${particle.x25}px`,
                  "--particle-y-25": `${particle.y25}px`,
                  "--particle-x-50": `${particle.x50}px`,
                  "--particle-y-50": `${particle.y50}px`,
                  "--particle-x-75": `${particle.x75}px`,
                  "--particle-y-75": `${particle.y75}px`,
                  "--particle-x-100": `${particle.x100}px`,
                  "--particle-y-100": `${particle.y100}px`,
                  "--particle-rotation-25": `${particle.rotation25}rad`,
                  "--particle-rotation-50": `${particle.rotation50}rad`,
                  "--particle-rotation-75": `${particle.rotation75}rad`,
                  "--particle-rotation-100": `${particle.rotation100}rad`,
                  "--particle-trail-rotation": `${particle.trailRotation}rad`,
                  "--particle-scale": particle.scale,
                  "--particle-scale-25": particle.scale25,
                  "--particle-scale-50": particle.scale50,
                  "--particle-scale-75": particle.scale75,
                  "--particle-scale-end": particle.scaleEnd,
                  "--particle-duration": `${particle.duration}ms`,
                } as CSSProperties
              }
              onAnimationEnd={() =>
                setParticles((currentParticles) =>
                  currentParticles.filter((item) => item.id !== particle.id),
                )
              }
            >
              <span className="particle-trail" aria-hidden="true" />
              <img className="particle-heart" src={particle.texture} alt="" />
            </span>
          ))}
        </button>
      </section>
    </main>
  );
}

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
