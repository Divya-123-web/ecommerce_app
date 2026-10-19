class Responsive {
  Responsive._();

  static int gridColumns(double width) {
    if (width >= 1000) return 4;
    if (width >= 700) return 3;
    return 2; // normal phones
  }

  static double gridAspectRatio(double width) => width >= 700 ? 0.78 : 0.68;
}