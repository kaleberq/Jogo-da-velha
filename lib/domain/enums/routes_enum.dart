enum RoutesEnum {
  splash(path: '/'),
  menu(path: '/menu'),
  localGame(path: '/local-game'),
  onlineGame(path: '/online-game');

  final String path;

  const RoutesEnum({required this.path});
}
