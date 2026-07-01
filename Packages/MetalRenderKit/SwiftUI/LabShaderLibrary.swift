import SwiftUI

public enum LabShaderLibrary {
    public static func symbolLightSweep(
        size: CGSize,
        time: Float,
        parameters: SymbolLightSweepParameters = .standard
    ) -> Shader {
        Shader(
            function: ShaderFunction(
                library: .bundle(.module),
                name: "lab_symbol_light_sweep"
            ),
            arguments: [
                .float2(size),
                .float(time),
                .float(parameters.cycleDuration),
                .float(parameters.sweepDuration),
                .float(parameters.angle),
                .float(parameters.softness),
                .float(parameters.intensity),
            ]
        )
    }
}
