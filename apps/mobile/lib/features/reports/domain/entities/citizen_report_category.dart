enum CitizenReportCategory {
  roadDamage('Road Damage'),
  flooding('Flooding'),
  wasteManagement('Waste Management'),
  streetLighting('Street Lighting'),
  publicSafety('Public Safety'),
  others('Others');

  const CitizenReportCategory(this.apiValue);

  final String apiValue;
}
