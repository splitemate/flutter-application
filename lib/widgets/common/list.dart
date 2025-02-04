import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SimpleList extends StatelessWidget {
  final List<Map<String, String>> items;

  const SimpleList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MouseRegion(
          onEnter: (_) {
          },
          onExit: (_) {
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: SvgPicture.asset(
                      item['iconPath']!,
                      width: 24,
                      height: 24,
                    ),
                    title: Text(item['name']!),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        child: const SizedBox(
          height: 1,
          child: Divider(),
        ),
      ),
    );
  }
}