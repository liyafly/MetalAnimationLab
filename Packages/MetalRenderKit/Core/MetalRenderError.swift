import Foundation

public enum MetalRenderError: Error, Equatable, Sendable {
    case deviceUnavailable
    case commandQueueUnavailable
    case shaderLibraryUnavailable(String)
    case shaderFunctionUnavailable(String)
    case pipelineCreationFailed(String)
    case invalidSampleCount(Int)
}

extension MetalRenderError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .deviceUnavailable:
            "Metal is unavailable on this device."
        case .commandQueueUnavailable:
            "Metal could not create a command queue."
        case let .shaderLibraryUnavailable(reason):
            "The Metal shader library could not be loaded: \(reason)"
        case let .shaderFunctionUnavailable(name):
            "The Metal shader function '\(name)' was not found."
        case let .pipelineCreationFailed(reason):
            "The Metal render pipeline could not be created: \(reason)"
        case let .invalidSampleCount(count):
            "The sample count must be positive; received \(count)."
        }
    }
}

