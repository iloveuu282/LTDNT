import 'package:flutter/material.dart';
import 'package:trek_bikes_app/order.dart';
import 'package:trek_bikes_app/order_repository.dart';
import 'package:trek_bikes_app/session_helper.dart';
import 'package:trek_bikes_app/status.dart';
import 'package:trek_bikes_app/status_repository.dart';

class OrderPage extends StatefulWidget {
  final String title;

  const OrderPage({super.key, required this.title});

  @override
  State<StatefulWidget> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Order> _orders = [];
  List<Status> _statuses = [];
  int? _orderId;
  int? _statusId;

  Future<void> _loadOrders() async {
    try {
      String? token = await SessionHelper.token;
      if (token == null) return;
      var data = await OrderRepository.getOrders(token);
      if (!mounted) return;
      setState(() {
        _orders = data;
      });
    } catch (_) {
      if (mounted) _showMessage('Failed to load orders');
    }
  }

  Future<void> _loadStatuses() async {
    try {
      var data = await StatusRepository.getStatuses();
      if (!mounted) return;
      setState(() {
        _statuses = data;
      });
    } catch (_) {
      if (mounted) _showMessage('Failed to load statuses');
    }
  }
  @override
  void initState() {
    super.initState();
    _loadOrders();
    _loadStatuses();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          Order item = _orders[index];
          return ListTile(
            leading: Text(item.id.toString()),
            title: Text(item.statusName ?? ''),
            trailing: ElevatedButton.icon(
              onPressed: () => _onDetails(item),
              label: Text('Details'),
            ),
          );
        },
      ),
    );
  }
  void _onDetails(Order obj) async {
    if (_statuses.isEmpty) {
      await _loadStatuses();
      if (!mounted) return;
      if (_statuses.isEmpty) return;
    }
    _orderId = obj.id;
    _statusId = obj.statusId;
    final save = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(obj.id.toString()),
              DropdownButtonFormField<int>(
                initialValue: _statuses.any((p) => p.id == _statusId)
                    ? _statusId
                    : null,
                items: _statuses.map((p) {
                  return DropdownMenuItem<int>(
                    value: p.id,
                    child: Text(p.name),
                  );
                }).toList(),
                onChanged: (value) {
                  _statusId = value;
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: _onCancel,
              label: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              label: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (save == true && mounted) await _onSave();
  }

  void _onCancel() {
    Navigator.pop(context, false);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onSave() async {
    if (_orderId == null || _statusId == null) return;
    try {
      String? token = await SessionHelper.token;
      if (!mounted) return;
      if (token == null) {
        _showMessage('Please sign in again');
        return;
      }
      int ret = await OrderRepository.update(
        Order(
          id: _orderId,
          memberId: null,
          statusId: _statusId!,
          statusName: null,
        ),
        token,
      );
      if (!mounted) return;
      if (ret > 0) {
        _showMessage('Update Success');
        await _loadOrders();
      } else {
        _showMessage('Update failed');
      }
    } catch (_) {
      if (mounted) _showMessage('Update failed');
    }
  }
}
