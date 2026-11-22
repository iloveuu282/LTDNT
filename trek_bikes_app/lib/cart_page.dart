import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trek_bikes_app/cart_ex.dart';
import 'package:trek_bikes_app/cart_repository.dart';
import 'package:trek_bikes_app/order.dart';
import 'package:trek_bikes_app/order_repository.dart';
import 'package:trek_bikes_app/session_helper.dart';

class CartPage extends StatefulWidget {
  final String title;

  const CartPage({super.key, required this.title});

  @override
  State<StatefulWidget> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartEx> _carts = [];
  bool _loading = true;
  String? _loadError;

  void _loadCarts() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      String? token = await SessionHelper.token;
      if (token == null) {
        if (mounted) setState(() => _loadError = 'Please login');
        return;
      }
      var data = await CartRepository.getCarts(token);
      if (!mounted) return;
      setState(() {
        _carts = data;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loadError = 'Failed to load cart. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCarts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator(),
          if (_loadError != null) ...[
            Text(_loadError!),
            TextButton(onPressed: _loadCarts, child: const Text('Retry')),
          ],
          _loadTable(),
          ElevatedButton.icon(
            onPressed: _loading || _loadError != null ? null : _onCheckout,
            label: Text('Checkout'),
            icon: Icon(Icons.check_outlined),
          ),
        ],
      ),
    );
  }

  void _onCheckout() async {
    if (_carts.isEmpty) {
      _showMessage('Cart is empty');
      return;
    }
    String? token = await SessionHelper.token;
    if (!mounted) return;
    if (token == null) {
      _showMessage('Please login');
      return;
    }

    try {
      Order obj = Order(id: null, memberId: null, statusId: 1, statusName: null);
      int ret = await OrderRepository.save(obj, token);
      if (!mounted) return;
      if (ret > 0) {
        _showMessage('Checkout success');
        Navigator.popAndPushNamed(context, '/order');
      } else {
        _showMessage('Checkout failed');
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('Checkout failed');
    }
  }

  Widget _loadTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Image')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Quantity')),
          DataColumn(label: Text('Command')),
        ],
        rows: _carts.map((CartEx item) {
          return DataRow(
            cells: [
              DataCell(Text(item.name)),
              DataCell(
                Image.network(
                  '${dotenv.env['API_URL']}/bikes/${item.imageUrl}',
                  width: 128,
                ),
              ),
              DataCell(Text(item.price.toString())),
              DataCell(Text(item.quantity.toString())),
              DataCell(
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _onDelete(item.bikeId),
                      label: Text('Delete'),
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _onDelete(int id) async {
    String? token = await SessionHelper.token;

    if (token != null) {
      int ret = await CartRepository.delete(id, token);

      if (!mounted) return;

      if (ret > 0) {
        _loadCarts();
        _showMessage('Delete success');
      } else {
        _showMessage('Delete failed');
      }
    } else {
      if (!mounted) return;
      _showMessage('Please login');
    }
  }
}
