# Layer Tree

Core Animation separates the model values stored on a layer from presentation values visible during an animation. EXP-001 makes the geometry relationship concrete by keeping `bounds` and `anchorPoint` stable while deriving `position` from the host view.

The UIKit and AppKit hosts use different view lifecycles, but both attach the same CALayer scene and record the same geometry fields.

