//
//  ContentView.swift
//  chips-emoji
//
//  Created by k zhukovskaya on 27.05.2026.
//

import SwiftUI
import UIKit
import Lottie

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Image(uiImage: csatImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                pleasantSurpriseChip
                    .padding(.top, geometry.size.height * 0.525)
            }
        }
        .ignoresSafeArea()
    }

    private var pleasantSurpriseChip: some View {
        PleasantSurpriseChip()
    }

    private var csatImage: UIImage {
        if let image = UIImage(named: "csat2x") {
            return image
        }

        guard
            let path = Bundle.main.path(forResource: "csat2x", ofType: "png"),
            let image = UIImage(contentsOfFile: path)
        else {
            return UIImage()
        }

        return image
    }
}

private struct PleasantSurpriseChip: View {
    @State private var isPressed = false
    @State private var isActive = false
    @State private var smileTrigger = 0
    @State private var shimmerTrigger = 0
    @State private var burstTrigger = 0
    @State private var burstParticles: [BurstParticle] = []

    private let chipColor = Color(red: 0, green: 16 / 255, blue: 36 / 255)
    private let activeChipColor = Color(red: 66 / 255, green: 139 / 255, blue: 249 / 255)
    private let smileSize: CGFloat = 34

    var body: some View {
        chipBody
        .contentShape(Capsule())
        .simultaneousGesture(pressGesture)
    }

    private var chipBody: some View {
        ZStack(alignment: .topLeading) {
            chipBase

            if !burstParticles.isEmpty {
                BurstView(particles: burstParticles)
                    .id(burstTrigger)
                    .offset(x: 19, y: 13)
                    .allowsHitTesting(false)
            }

            smileLayer
                .offset(x: 2, y: -2)
        }
    }

    private var chipBase: some View {
        HStack(spacing: 2) {
            Color.clear
                .frame(width: smileSize, height: smileSize)

            chipText
        }
        .padding(.leading, 2)
        .padding(.trailing, 8)
        .frame(height: 30)
        .background(isActive ? activeChipColor : chipColor.opacity(0.03))
        .clipShape(Capsule())
        .overlay {
            if shimmerTrigger > 0 {
                ShimmerView(trigger: shimmerTrigger)
                    .clipShape(Capsule())
                    .allowsHitTesting(false)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isActive)
    }

    private var smileLayer: some View {
        LottieSmileIcon(trigger: smileTrigger)
        .frame(width: smileSize, height: smileSize)
    }

    private var chipText: some View {
        Text("Приятно удивило")
            .font(.system(size: 13, weight: .semibold))
            .tracking(-0.08)
            .lineLimit(1)
            .foregroundStyle(isActive ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.2))
    }

    private var pressGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard !isPressed else { return }
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    isPressed = true
                }
            }
            .onEnded { _ in
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    isPressed = false
                }
                pressUp()
            }
    }

    private func pressUp() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
        }

        if isActive {
            playSmile()
            burstTrigger += 1
            burstParticles = BurstParticle.makeBurst()
            runShimmer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                burstParticles = []
            }
            return
        }

        withAnimation(.easeInOut(duration: 0.25)) {
            isActive = true
        }
        playSmile()
        burstTrigger += 1
        burstParticles = BurstParticle.makeBurst()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            runShimmer()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            burstParticles = []
        }
    }

    private func runShimmer() {
        shimmerTrigger += 1
    }

    private func playSmile() {
        smileTrigger += 1
    }
}

private struct LottieSmileIcon: View {
    let trigger: Int

    var body: some View {
        LottieSmileAnimation(trigger: trigger)
            .frame(width: 34, height: 34)
    }
}

private struct LottieSmileAnimation: UIViewRepresentable {
    let trigger: Int

    func makeUIView(context: Context) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        container.clipsToBounds = false

        let animationView = LottieAnimationView(name: "icon-starface")
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.currentFrame = 0
        animationView.clipsToBounds = false

        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalToConstant: 34),
            animationView.heightAnchor.constraint(equalToConstant: 34),
            animationView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        context.coordinator.animationView = animationView
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard trigger > 0 else { return }
        guard let animationView = context.coordinator.animationView else { return }
        animationView.stop()
        animationView.currentFrame = 0
        animationView.play(fromFrame: 0, toFrame: 40, loopMode: .playOnce)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIView, context: Context) -> CGSize? {
        CGSize(width: 34, height: 34)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var animationView: LottieAnimationView?
    }
}

private struct ShimmerView: View {
    let trigger: Int

    @State private var progress = 0.0

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        .white.opacity(0),
                        .white.opacity(0.72),
                        .white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 54, height: 42)
            .blur(radius: 1)
            .rotationEffect(.degrees(-16))
            .opacity(shimmerOpacity)
            .offset(x: -54 + 238 * progress)
            .onAppear(perform: play)
            .onChange(of: trigger) { _, _ in
                play()
            }
    }

    private var shimmerOpacity: Double {
        if progress < 0.18 {
            return progress / 0.18
        }
        return max(0, 1 - ((progress - 0.18) / 0.82))
    }

    private func play() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            progress = 0
        }
        withAnimation(.easeOut(duration: 0.62)) {
            progress = 1
        }
    }
}

private struct BurstView: View {
    let particles: [BurstParticle]

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                BurstParticleView(particle: particle)
            }
        }
        .frame(width: 1, height: 1)
    }
}

private struct BurstParticleView: View {
    let particle: BurstParticle

    @State private var progress = 0.0

    var body: some View {
        ZStack {
            TrailView(particle: particle, progress: progress)

            Image(particle.assetName)
                .resizable()
                .frame(width: 44.93, height: 44.93)
                .scaleEffect(scale)
                .rotationEffect(.degrees(particle.rotation * progress))
                .opacity(opacity)
        }
        .offset(x: particle.x * progress, y: particle.y(progress))
        .animation(.linear(duration: particle.duration).delay(particle.delay), value: progress)
        .onAppear {
            progress = 1
        }
    }

    private var scale: Double {
        particle.startScale + (particle.endScale - particle.startScale) * progress
    }

    private var opacity: Double {
        switch progress {
        case 0..<0.25:
            return 1 - (0.3 * progress / 0.25)
        case 0.25..<0.5:
            return 0.7 - (0.3 * (progress - 0.25) / 0.25)
        case 0.5..<0.75:
            return 0.4 - (0.24 * (progress - 0.5) / 0.25)
        default:
            return max(0, 0.16 - (0.16 * (progress - 0.75) / 0.25))
        }
    }
}

private struct TrailView: View {
    let particle: BurstParticle
    let progress: Double

    var body: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        .white.opacity(0),
                        .white.opacity(0.46),
                        .white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 68, height: 18)
            .blur(radius: 4)
            .scaleEffect(x: scaleX, y: 1, anchor: .trailing)
            .opacity(opacity)
            .rotationEffect(.degrees(particle.angleDegrees + 180))
            .offset(x: -18, y: 0)
    }

    private var opacity: Double {
        switch progress {
        case 0..<0.08:
            return 0
        case 0.08..<0.18:
            return 0.63 * ((progress - 0.08) / 0.1)
        case 0.18..<0.38:
            return 0.63 - (0.35 * ((progress - 0.18) / 0.2))
        default:
            return max(0, 0.28 * (1 - ((progress - 0.38) / 0.62)))
        }
    }

    private var scaleX: Double {
        switch progress {
        case 0..<0.08:
            return 0.3 + (0.24 * progress / 0.08)
        case 0.08..<0.18:
            return 0.54 + (0.26 * ((progress - 0.08) / 0.1))
        case 0.18..<0.38:
            return 0.8 - (0.22 * ((progress - 0.18) / 0.2))
        default:
            return max(0.22, 0.58 - (0.36 * ((progress - 0.38) / 0.62)))
        }
    }
}

private struct BurstParticle: Identifiable {
    let id = UUID()
    let assetName: String
    let delay: Double
    let duration: Double
    let angleDegrees: Double
    let x: Double
    let baseY: Double
    let gravityY: Double
    let startScale: Double
    let endScale: Double
    let rotation: Double

    func y(_ progress: Double) -> Double {
        baseY * progress + gravityY * progress * progress
    }

    static func makeBurst() -> [BurstParticle] {
        (0..<18).map { index in
            let angle = Double.random(in: 0..<360)
            let radians = angle * .pi / 180
            let lifetime = Double.random(in: 0.65...1.15)
            let velocity = Double.random(in: 49...175)
            let distance = velocity * lifetime * 0.7
            let scale = max(0.18, Double.random(in: 0.38...0.46))
            let endScale = max(0.08, scale + (-0.25 * lifetime))

            return BurstParticle(
                assetName: "star-\((index % 4) + 1)",
                delay: Double(index) / 120,
                duration: lifetime,
                angleDegrees: angle,
                x: cos(radians) * distance,
                baseY: sin(radians) * distance,
                gravityY: 80 * lifetime * lifetime * 0.7,
                startScale: scale,
                endScale: endScale,
                rotation: Double.random(in: -220...220)
            )
        }
    }
}

#Preview("375 x 812") {
    ContentView()
        .previewLayout(.fixed(width: 375, height: 812))
}
