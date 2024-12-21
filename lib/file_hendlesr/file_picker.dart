// lib/file_picker.dart

// Всегда экспортируем интерфейс
export 'file_picker_interface.dart';

// Если доступна платформа HTML (веб), то экспортируем file_picker_web.dart,
// в противном случае (мобильные/десктоп) — file_picker_mobile.dart.
export 'file_handler_mobile.dart'
if (dart.library.html) 'file_handler_web.dart';
