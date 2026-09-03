import 'package:flutter/material.dart';
import 'offer_details_screen.dart';

class MyOffersScreen extends StatelessWidget {
  const MyOffersScreen({super.key});

  void _openOfferDetails(
    BuildContext context, {
    required String crop,
    required String quantity,
    required String location,
    required String askingPrice,
    required String yourOffer,
    required String totalValue,
    required String status,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferDetailsScreen(
          crop: crop,
          quantity: quantity,
          location: location,
          askingPrice: askingPrice,
          yourOffer: yourOffer,
          totalValue: totalValue,
          status: status,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Offers'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openOfferDetails(
                  context,
                  crop: 'Wheat',
                  quantity: '100 qtl',
                  location: 'Meerut',
                  askingPrice: '₹2,450/qtl',
                  yourOffer: '₹2,400/qtl',
                  totalValue: '₹2,40,000',
                  status: 'Pending',
                ),
                child: const ListTile(
                  title: Text('Wheat — 100 qtl'),
                  subtitle: Text('Location: Meerut\nYour Offer: ₹2,400/qtl'),
                  trailing: Text(
                    'Pending',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openOfferDetails(
                  context,
                  crop: 'Wheat',
                  quantity: '150 qtl',
                  location: 'Muzaffarnagar',
                  askingPrice: '₹2,480/qtl',
                  yourOffer: '₹2,450/qtl',
                  totalValue: '₹3,67,500',
                  status: 'Accepted',
                ),
                child: const ListTile(
                  title: Text('Wheat — 150 qtl'),
                  subtitle: Text('Location: Muzaffarnagar\nYour Offer: ₹2,450/qtl'),
                  trailing: Text(
                    'Accepted',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openOfferDetails(
                  context,
                  crop: 'Rice',
                  quantity: '80 qtl',
                  location: 'Hapur',
                  askingPrice: '₹3,100/qtl',
                  yourOffer: '₹3,050/qtl',
                  totalValue: '₹2,44,000',
                  status: 'Rejected',
                ),
                child: const ListTile(
                  title: Text('Rice — 80 qtl'),
                  subtitle: Text('Location: Hapur\nYour Offer: ₹3,050/qtl'),
                  trailing: Text(
                    'Rejected',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openOfferDetails(
                  context,
                  crop: 'Wheat',
                  quantity: '200 qtl',
                  location: 'Bulandshahr',
                  askingPrice: '₹2,475/qtl',
                  yourOffer: '₹2,460/qtl',
                  totalValue: '₹4,92,000',
                  status: 'Pending',
                ),
                child: const ListTile(
                  title: Text('Wheat — 200 qtl'),
                  subtitle: Text('Location: Bulandshahr\nYour Offer: ₹2,460/qtl'),
                  trailing: Text(
                    'Pending',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}