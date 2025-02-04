import 'package:flutter/material.dart';
import 'package:splitemate/widgets/cards/transaction_card.dart';

class PersonalLedgerListTile extends StatelessWidget {
  final List<Map<String, dynamic>> data = [
    {
      'name': 'Jerome Bell',
      'time': '2 hours ago',
      'amount': 1420.45,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCP22MsBh-99tBCI4MLmAnziP32oNy-afGoA&s',
      'isPositive': true,
    },
    {
      'name': 'Anna Smith',
      'time': '5 hours ago',
      'amount': 4534.30,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRYxsG3Ac8-CCLG3PzEvZXAfVoQxmjHleJqjg&s',
      'isPositive': false,
    },
    {
      'name': 'Michael Johnson',
      'time': '1 day ago',
      'amount': 783.20,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHDRlp-KGr_M94k_oor4Odjn2UzbAS7n1YoA&s',
      'isPositive': true,
    },
    {
      'name': 'Emily Davis',
      'time': '3 days ago',
      'amount': 1299.99,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTvJaoIeJQU_V9rL_ZII61whWyqSFbmMgTgwQ&s',
      'isPositive': true,
    },
    {
      'name': 'David Wilson',
      'time': '6 days ago',
      'amount': 675.50,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSeJmFW_rzPyuJUmTEmTk9ZLB7u1CmTclyKCA&s',
      'isPositive': false,
    },
    {
      'name': 'Sophia Lee',
      'time': '2 days ago',
      'amount': 999.00,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSsb_V_Ha4XAl47doWf_2lF-actuld60ssYew&s',
      'isPositive': true,
    },
    {
      'name': 'John Brown',
      'time': '7 hours ago',
      'amount': 450.75,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRQi2Mm5P8j09P4hPKa1B-t9eIOHzHmR7IBkw&s',
      'isPositive': false,
    },
    {
      'name': 'Olivia Martinez',
      'time': '4 days ago',
      'amount': 2350.00,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQjl7xYqho8VFxvJSR9heh8UTerI6FW4KDbxA&s',
      'isPositive': true,
    },
    {
      'name': 'James Anderson',
      'time': '1 week ago',
      'amount': 550.00,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRij6dtiHizH96qpCOe8WeXXP3yLyQJkPdGVg&s',
      'isPositive': false,
    },
    {
      'name': 'Isabella Thomas',
      'time': '3 days ago',
      'amount': 1200.45,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5q9GlWCAoQHPpOiDOECuYUeXW9MQP7Ddt-Q&s',
      'isPositive': true,
    },
    {
      'name': 'Lucas Taylor',
      'time': '2 hours ago',
      'amount': 789.30,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTw0PDKrErulLlbJkbv5KtsCeICczdgJSyurA&s',
      'isPositive': true,
    },
    {
      'name': 'Ava Anderson',
      'time': '5 days ago',
      'amount': 340.20,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6Hb5xzFZJCTW4cMqmPwsgfw-gILUV7QevvQ&s',
      'isPositive': false,
    },
    {
      'name': 'Ethan Harris',
      'time': '1 day ago',
      'amount': 1150.60,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3aQlh8O7bgyLqxpvp4ZHA8sozFmfh3quzMQ&s',
      'isPositive': true,
    },
    {
      'name': 'Mia Clark',
      'time': '8 hours ago',
      'amount': 910.45,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSvGbfnYcCWLB505FNa8JQIJ77h_hN5W_SXKA&s',
      'isPositive': true,
    },
    {
      'name': 'Benjamin Lewis',
      'time': '4 hours ago',
      'amount': 622.75,
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZR6Gs7vDfFNNMsCAc2pNG0LaG3xAgnZDapQ&s',
      'isPositive': false,
    },
    {
      'name': 'Charlotte Walker',
      'time': '2 days ago',
      'amount': 1700.90,
      'imageUrl': 'https://media.istockphoto.com/id/1338134319/photo/portrait-of-young-indian-businesswoman-or-school-teacher-pose-indoors.jpg?s=612x612&w=0&k=20&c=Dw1nKFtnU_Bfm2I3OPQxBmSKe9NtSzux6bHqa9lVZ7A=',
      'isPositive': true,
    },
  ];


  PersonalLedgerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(top: size.width * 0.044),
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return TransactionCard(
            name: item['name'],
            time: item['time'],
            amount: item['amount'],
            imageUrl: item['imageUrl'],
            isPositive: item['isPositive'],
          );
        },
      ),
    );
  }
}
