import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trek_bikes_app/bike.dart';
import 'package:trek_bikes_app/bike_repository.dart';
import 'package:trek_bikes_app/cart.dart';
import 'package:trek_bikes_app/cart_repository.dart';
import 'package:trek_bikes_app/session_helper.dart';

class DetailsPage extends StatefulWidget {
  final String title;

  const DetailsPage({super.key, required this.title});

  @override
  State<StatefulWidget> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Bike? _bike;
  List<Bike> _relation = [];
  int? id;
  String? _error;
  bool _addingToCart = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (id == null) {
      id = ModalRoute.of(context)!.settings.arguments as int;
      _loadBike();
    }
  }

  void _loadBike() async {
    var item = await BikeRepository.getBike(id!);
    var data = await BikeRepository.getBikesRelation(
      item.id,
      item.subCategoryId,
    );

    if (!mounted) return;

    setState(() {
      _bike = item;
      _relation = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_bike != null) ...[
              Image.network(
                '${dotenv.env['API_URL']}/bikes/${_bike!.imageUrl}',
                width: 512,
              ),
              Text(_bike!.name),
              _loadTable(_bike!),
              ElevatedButton.icon(
                onPressed: _addingToCart ? null : () => _onAddToCart(_bike!),
                label: Text(_addingToCart ? 'Adding...' : 'Add to Cart'),
                icon: const Icon(Icons.shopping_bag),
              ),
              if (_error != null) Text(_error!),
            ],
            if (_relation.isNotEmpty) _loadGridView(_relation),
          ],
        ),
      ),
    );
  }

  Future<void> _onAddToCart(Bike bike) async {
    if (_addingToCart) return;
    setState(() {
      _addingToCart = true;
      _error = null;
    });
    try {
      final token = await SessionHelper.token;
      if (!mounted) return;
      if (token == null) {
        setState(() => _error = 'Please login');
        return;
      }
      final result = await CartRepository.add(
        Cart(memberId: null, bikeId: bike.id, quantity: 1),
        token,
      );
      if (!mounted) return;
      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to cart')),
        );
      } else {
        setState(() => _error = 'Failed to add to cart');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Failed to add to cart. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  Widget _loadGridView(List<Bike> relation) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: relation.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (context, index) {
        Bike item = relation[index];
        return Column(
          children: [
            Image.network(
              '${dotenv.env['API_URL']}/bikes/${item.imageUrl}',
              width: 128,
            ),
            Text(item.name),
            Text('Price: ${item.price}'),
            ElevatedButton.icon(
              onPressed: () => _details(item.id),
              label: const Text('Details'),
              icon: const Icon(Icons.info),
            ),
          ],
        );
      },
    );
  }

  Widget _loadTable(Bike bike) {
    return Table(
      children: [
        TableRow(
          children: [
            const TableCell(child: Text("Price")),
            TableCell(child: Text(bike.price.toString())),
          ],
        ),
        if (bike.fork != null)
          TableRow(
            children: [
              const TableCell(child: Text("Fork")),
              TableCell(child: Text(bike.fork!)),
            ],
          ),
        if (bike.frame != null)
          TableRow(
            children: [
              const TableCell(child: Text("Frame")),
              TableCell(child: Text(bike.frame!)),
            ],
          ),
        if (bike.brakes != null)
          TableRow(
            children: [
              const TableCell(child: Text("Brakes")),
              TableCell(child: Text(bike.brakes!)),
            ],
          ),
        if (bike.wheels != null)
          TableRow(
            children: [
              const TableCell(child: Text("Wheels")),
              TableCell(child: Text(bike.wheels!)),
            ],
          ),
        if (bike.weight != null)
          TableRow(
            children: [
              const TableCell(child: Text("Weight")),
              TableCell(child: Text(bike.weight!)),
            ],
          ),
        if (bike.rearShock != null)
          TableRow(
            children: [
              const TableCell(child: Text("RearShock")),
              TableCell(child: Text(bike.rearShock!)),
            ],
          ),
        if (bike.drivetrain != null)
          TableRow(
            children: [
              const TableCell(child: Text("Drivetrain")),
              TableCell(child: Text(bike.drivetrain!)),
            ],
          ),
        if (bike.tires != null)
          TableRow(
            children: [
              const TableCell(child: Text("Tires")),
              TableCell(child: Text(bike.tires!)),
            ],
          ),
      ],
    );
  }

  void _details(int id) {
    Navigator.pushNamed(
      context,
      '/details',
      arguments: id,
    );
  }
}
