enum PageOptionType { users, profile, loggout }

class PageOption {
  String name;
  PageOptionType type;
  PageOption({required this.name, required this.type});
}

List<PageOption> options = [
  PageOption(name: 'Ver Usuarios', type: PageOptionType.users),
  PageOption(name: 'Ver Perfil', type: PageOptionType.profile),
  PageOption(name: 'Cerrar Sesion', type:PageOptionType.loggout)
];