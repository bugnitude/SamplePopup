# Overview
This is a sample iOS project using SwiftUI that demonstrates how to display a popup.

![Screenshots](https://github.com/bugnitude/SamplePopup/blob/master/README_IMAGES/Screenshots.png)

SwiftUI provides features like the __popover__ modifier, the __contextMenu__ modifier, and the __Menu__ view for displaying popups on top of the main content. However, these features often lack flexibility and customization options. This project introduces a highly flexible implementation for displaying arbitrary views as popups.

By applying the implementation from this project, it becomes easy to implement other overlay contents, such as custom alerts and toasts.

# Details
This section provides detailed explanations of the components in this project.

Here is the view hierarchy. The names shown in bold are the types used within the project.

![View Hierarchy](https://github.com/bugnitude/SamplePopup/blob/master/README_IMAGES/ViewHierarchy.png)

In this project, a popup is displayed on top of the __PassthroughWindow__, which is a window shown in front of the main window. This ensures that the displayed popup will appear in front of all the views presented as the main content.

The following provides detailed descriptions of the main types used in this project.

## PassThroughWindow, OverlayView
The __PassthroughWindow__ is a subclass of __UIWindow__ that is always displayed in front of the main window. In the __PassthroughWindow__, the __hitTest(_:)__ method is overridden to ensure that user interactions with the main content are not consumed.

The __OverlayView__ is a SwiftUI view that is displayed on the __PassthroughWindow__. Above the __OverlayView__, the __PopupContainer__ mentioned later is displayed, and any SwiftUI view can be displayed as a popup on the view.

Within the scope of this project, the __OverlayView__ is actually unnecessary, and it would be sufficient to place the __PopupContainer__ directly on the __PassthroughWindow__. However, the decision to introduce this additional view was made to minimize changes to the existing code when displaying other overlay contents on the __PassthroughWindow__.

## SamplePopupApp, AppDelegate, SceneDelegate
The __SamplePopupApp__ conforms to the __App__ protocol, the __AppDelegate__ conforms to the __UIApplicationDelegate__ protocol, and the __SceneDelegate__ conforms to the __UIWindowSceneDelegate__ protocol.

In the __SamplePopupApp__, the __AppDelegate__ is made available for use within the code.

In the __AppDelegate__, the __SceneDelegate__ is associated with the app via the __UISceneConfiguration__'s __delegateClass__.

In the __SceneDelegate__, the previously mentioned __PassthroughWindow__ is associated with the app's scene. The __rootViewController__ of the window is set using __UIHostingController__ with the previously mentioned __OverlayView__ as its __rootView__.

It is important to note that a reference to the __PassthroughWindow__ must be retained in the __SceneDelegate__. Without this reference, the window and its overlaid contents will not be displayed.

## Popup
The __Popup__ class conforms to the __ObservableObject__ protocol. This class provides methods for displaying and hiding popups.

The popups are actually displayed on the __PopupContainer__ mentioned later, and multiple popups cannot be displayed simultaneously.

To display a popup, the following information is required:
* Source Frame: The frame of the source from which the popup originates (the origin is in the global coordinate space).
* Width: The width of the popup.
* View: The view to be displayed as the popup.

It is possible to display and hide popups directly using the methods of this class. However, to simplify the implementation, this project uses the __PopupModifier__ mentioned later to handle the presentation and dismissal of popups indirectly.

Since the current implementation does not include the logic for changing the keyWindow, if you need the logic, please implement it in processes such as displaying and hiding popups.

## PopupModifier
The __PopupModifier__ is a modifier used to display and hide a popup using the previously mentioned __Popup__ class. The modifier named __PopupModifier__ is private and can be used as an extension method of the __View__ as shown below.

```
func popup<Content>(isPresented: Binding<Bool>, width: CGFloat = .infinity, @ViewBuilder content: @escaping (Popup.AnchorPosition) -> Content) -> some View where Content: View
```

The view to which this modifier is applied will make its frame used as the source from which the popup originates.

## PopupContainer
The __PopupContainer__ is a container view for displaying popups, which uses the information received through the previously mentioned __PopupModifier__ and __Popup__.

The main tasks of this view are as follows:
* Determining the popup's display position
* Adjusting the size of the popup
* Controlling the animations when displaying or hiding the popup

The position of the popup is determined based on the frame of its source. Horizontally, the popup is aligned relative to the source frame using leading, center, or trailing alignment. Vertically, the popup is displayed either above or below the source frame.

In this project's implementation, the position and size of the popup are adjusted to ensure it is displayed within the displayable area with margins defined in the implementation.

To determine the horizontal position, the width of the popup is specified via the modifier's argument. This value can be .infinity, in which case the maximum available width within the area mentioned above will be used. Explicitly setting the width directly on the view, as shown below, is not supported and may result in incorrect rendering.

```
SomeSourceView()
.popup(isPresented: self.$isPresented) {
  SomePopupView()
    .frame(width: 200)	  // <- Not supported
}
```

On the other hand, the height can be explicitly set, and for views whose height is determined dynamically, there is no need to specify it at all. However, if a height greater than the area mentioned above is explicitly specified, the popup will extend beyond the screen and be partially cut off.

The popup is displayed using __matchedGeometryEffect__, and the following two animations are executed during its presentation and dismissal:
* scaleEffect
* opacity

In the current implementation, the position of a source view is not tracked. Therefore, if a scroll occurs or the screen is rotated while the popup is displayed, the popup will remain at its original position, which becomes unrelated to the source view. Due to this issue, the popup is set to close when the screen is rotated.

When a popup is displayed, a view that disables interactions with the underlying main content is displayed at the very back, and tapping on this view will dismiss the popup.

## Files in Example folder
The files in the Example folder are examples of views for displaying popups.

# Requirements
* Xcode 16.0+
* Swift 5.0+
* iOS 17.0+

# References
* [How to layer multiple windows in SwiftUI](https://www.fivestars.blog/articles/swiftui-windows/)
* [Developer Forums > iOS 18 hit testing functionality differs from iOS 17](https://forums.developer.apple.com/forums/thread/762292)
* [MatchedGeometryEffect – Part 1 (Hero Animations)](https://swiftui-lab.com/matchedgeometryeffect-part1/)
* [MatchedGeometryEffect – Part 2](https://swiftui-lab.com/matchedgeometryeffect-part2/)