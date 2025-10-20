import 'dart:ffi';

typedef SetKeyboardLayoutFunc = Int32 Function(IntPtr);
typedef SetKeyboardLayout = int Function(int);

class KeyboardLayoutChanger {
  final DynamicLibrary user32 = DynamicLibrary.open('user32.dll');
  void changeKeyboardLayout(String layout) async {
    try {
      final SetKeyboardLayout setKeyboardLayout = user32
          .lookup<NativeFunction<SetKeyboardLayoutFunc>>(
              'ActivateKeyboardLayout')
          .asFunction();
      final int layoutId = layout == 'en' ? 0x0409 : 0x0C0A;
      setKeyboardLayout(layoutId);
    } catch (e) {
      rethrow;
    }
  }
}
