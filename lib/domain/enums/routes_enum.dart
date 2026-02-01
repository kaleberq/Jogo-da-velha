enum RoutesEnum {
  splash(path: '/splash'),
  menu(path: '/menu'),
  localOptions(path: '/local-options'),
  onlineOptions(path: '/online-options'),
  localGame(path: '/local-game'),
  onlineGame(path: '/online-game');

  final String path;

  const RoutesEnum({required this.path});
}
