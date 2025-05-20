import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:masters/data/api_service.dart';
import 'package:masters/data/user_session.dart';
import 'package:masters/models/request.dart';
import 'package:masters/models/user.dart';
import 'package:masters/models/service.dart';
import 'package:provider/provider.dart';
import 'package:masters/theme/settings.dart';
import 'package:masters/widgets/section_title.dart';
class MasterStatsPage extends StatefulWidget {
  const MasterStatsPage({super.key});

  @override
  State<MasterStatsPage> createState() => _MasterStatsPageState();
}

class _MasterStatsPageState extends State<MasterStatsPage> {
  final api = ApiService();
  double totalIncome = 0;
  int clientCount = 0;
  String topService = '';
  double averageAge = 0;
  DateTime selectedMonth = DateTime.now();
  Map<String, double> serviceIncomeMap = {};
  Map<int, double> dailyIncomeMap = {};
  int selectedWeek = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final masterId = UserSession().masterId;
      if (masterId == null) throw Exception('Master ID is null');

      final List<RequestModel> allRequests = await api.getReqMaster(masterId);
      final List<UserModel> users =
      (await api.getUsers()).map((user) => UserModel.fromJson(user)).toList();
      final List<ServiceModel> services =
      (await api.getServices()).map((service) => ServiceModel.fromJson(service)).toList();

      final filteredMonthRequests = allRequests.where((r) =>
      r.statusId == 1 &&
          r.startTime.year == selectedMonth.year &&
          r.startTime.month == selectedMonth.month).toList();

      totalIncome = filteredMonthRequests.fold<double>(0, (sum, r) => sum + double.parse(r.price));
      final clientIdsForMonth = filteredMonthRequests.map((r) => r.clientId).toSet();
      clientCount = clientIdsForMonth.length;

      serviceIncomeMap.clear();
      for (var r in filteredMonthRequests) {
        final sId = r.serviceId.toString();
        serviceIncomeMap[sId] = (serviceIncomeMap[sId] ?? 0) + double.parse(r.price);
      }

      dailyIncomeMap.clear();
      for (var r in filteredMonthRequests) {
        final day = r.startTime.day;
        dailyIncomeMap[day] = (dailyIncomeMap[day] ?? 0) + double.parse(r.price);
      }

      final completedRequests = allRequests.where((r) => r.statusId == 1).toList();
      final serviceCounts = <String, int>{};
      final allClientIds = completedRequests.map((r) => r.userId).toSet();

      for (var r in completedRequests) {
        final sId = r.serviceId.toString();
        serviceCounts[sId] = (serviceCounts[sId] ?? 0) + 1;
      }

      final topServiceId = serviceCounts.entries.isNotEmpty
          ? serviceCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : '-1';

      topService = services.firstWhere(
            (s) => s.serviceId.toString() == topServiceId,
        orElse: () => ServiceModel(
          serviceId: -1,
          serviceTypeId: -1,
          name: 'Неизвестно',
          duration: 0,
          price: 0.0,
          masterId: '',
        ),
      ).name;

      final ages = allClientIds.map((id) {
        final user = users.firstWhere(
              (u) => u.userId == id,
          orElse: () => UserModel.empty(),
        );
        return user.age;
      }).where((age) => age > 0).toList();

      averageAge = ages.isEmpty ? 0 : ages.reduce((a, b) => a + b) / ages.length;

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при загрузке статистики.')),
        );
      }
    }
  }

  List<int> getWeeksInMonth() {
    final daysInMonth = DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month);
    return List.generate(((daysInMonth + selectedMonth.weekday - 1) / 7).ceil(), (i) => i);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingApp>();
    final theme = settings.themeData.colorScheme;
    final fontSize = settings.fontSizeMultiplier;
    final fontFamily = settings.selectedFontFamily;

    final monthLabel = DateFormat.yMMMM('ru').format(selectedMonth);
    final headerStyle = TextStyle(
      fontSize: 18.0 * fontSize,
      fontFamily: fontFamily,
      fontWeight: FontWeight.bold,
      color: theme.inversePrimary,
    );

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const CustomTitle('Моя статистика'
        ),
        centerTitle: true,
        backgroundColor: theme.background.withOpacity(0.3),// Используем основной цвет
      ),
      body: Padding(
        padding: const EdgeInsets.all(6),
        child: ListView(
          children: [
            Text(monthLabel, style: headerStyle),
            const SizedBox(height: 3),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.6,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _statTileWithIcon(Icons.monetization_on, 'Доход за месяц', '${totalIncome.toStringAsFixed(2)} ₽', fontSize, fontFamily, theme),
                _statTileWithIcon(Icons.group, 'Количество клиентов', '$clientCount', fontSize, fontFamily, theme),
                _statTileWithIcon(Icons.star, 'Популярная услуга', topService, fontSize, fontFamily, theme),
                _statTileWithIcon(Icons.accessibility_new, 'Сред.возраст клиента', '${averageAge.toStringAsFixed(1)} лет', fontSize, fontFamily, theme),
              ],
            ),
            const SizedBox(height: 24),
            Text('Распределение дохода по услугам', style: headerStyle),
            const SizedBox(height: 12),
            _PieChartWrapper(dataMap: serviceIncomeMap, theme: theme),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Доход по дням недели', style: headerStyle),
                DropdownButton<int>(
                  value: selectedWeek,
                  dropdownColor: theme.background,
                  style: TextStyle(color: theme.inversePrimary),
                  items: getWeeksInMonth().map((week) => DropdownMenuItem(
                    value: week,
                    child: Text('Неделя ${week + 1}'),
                  )).toList(),
                  onChanged: (val) => setState(() => selectedWeek = val!),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _BarChartWrapper(
              data: Map.fromEntries(
                dailyIncomeMap.entries.where((e) {
                  final day = e.key;
                  final weekDay = DateTime(selectedMonth.year, selectedMonth.month, day).weekday;
                  final startDay = selectedWeek * 7 + 1;
                  return day >= startDay && day < startDay + 7;
                }),
              ),
              fontSize: fontSize,
              fontFamily: fontFamily,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTileWithIcon(IconData icon, String title, String value, double fontSize, String fontFamily, ColorScheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: theme.primary.withOpacity(0.1), blurRadius: 6)],
      ),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: theme.inversePrimary),
          const SizedBox(width: 3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 * fontSize, fontFamily: fontFamily, color: theme.inversePrimary)),
                const SizedBox(height: 1),
                Text(value, style: TextStyle(fontSize:14 * fontSize, fontFamily: fontFamily, color: theme.inversePrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PieChartWrapper extends StatelessWidget {
  final Map<String, double> dataMap;
  final ColorScheme theme;
  const _PieChartWrapper({required this.dataMap, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (dataMap.isEmpty) {
      return const Center(child: Text('Нет данных'));
    }

    final total = dataMap.values.fold(0.0, (a, b) => a + b);
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.brown,
    ];
    final api = ApiService();

    return FutureBuilder<List<ServiceModel>>(
      future: api.getServices().then((list) => list.map((e) => ServiceModel.fromJson(e)).toList()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final services = snapshot.data!;

        final entries = dataMap.entries.toList();
        final sections = entries.asMap().entries.map((entry) {
          final index = entry.key;
          final id = entry.value.key;
          final value = entry.value.value;
          final percent = (value / total) * 100;
          return PieChartSectionData(
            color: colors[index % colors.length],
            value: value,
            title: '${percent.toStringAsFixed(1)}%',
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 32,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: entries.asMap().entries.map((entry) {
                final index = entry.key;
                final color = colors[index % colors.length];
                final id = entry.value.key;
                final name = services.firstWhere(
                      (s) => s.serviceId.toString() == id,
                  orElse: () => ServiceModel(
                    serviceId: -1,
                    serviceTypeId: -1,
                    name: 'Неизвестно',
                    duration: 0,
                    price: 0.0,
                    masterId: '',
                  ),
                ).name;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, color: color),
                    const SizedBox(width: 4),
                    Text(name, style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _BarChartWrapper extends StatelessWidget {
  final Map<int, double> data;
  final double fontSize;
  final String fontFamily;

  const _BarChartWrapper({
    required this.data,
    required this.fontSize,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Text('Нет данных');

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'День ${val.toInt()}',
                    style: TextStyle(fontSize: 10 * fontSize, fontFamily: fontFamily),
                  ),
                ),
              ),
            ),
          ),
          barGroups: data.entries.map((entry) => BarChartGroupData(x: entry.key, barRods: [
            BarChartRodData(
              toY: entry.value,
              color: Colors.blue,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ])).toList(),
        ),
      ),
    );
  }
}
