// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:zc_tour_app/components/destination_details.dart';
// import 'package:zc_tour_app/screens/home/bloc/destination_bloc/destination_bloc.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// class DestinationTab extends StatefulWidget {
//   const DestinationTab({super.key});

//   @override
//   State<DestinationTab> createState() => _DestinationTabState();
// }

// class _DestinationTabState extends State<DestinationTab> with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<DestinationBloc, DestinationState>(
//       listener: (context, state) {
//         if (state is DestinationFailure) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to load destinations')),
//           );
//         }
//       },
//       child: Column(
//         children: [
//           TabBar(
//             controller: _tabController,
//             tabs: const [
//               Tab(text: '🏞️ Tourist Spots'),
//               Tab(text: 'Restaurants'),
//               Tab(text: 'Hotels'),
//             ],
//           ),
//           Flexible(
//             child: TabBarView(
//               controller: _tabController,
//               children: const [
//                 DestinationList(type: 'tourist_spots'),
//                 DestinationList(type: 'restaurants'),
//                 DestinationList(type: 'hotels'),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class DestinationList extends StatelessWidget {
//   final String type;

//   const DestinationList({super.key, required this.type});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<DestinationBloc, DestinationState>(
//       builder: (context, state) {
//         if (state is DestinationLoading) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (state is DestinationSuccess) {
//           List<dynamic> items;
//           switch (type) {
//             case 'tourist_spots':
//               items = state.touristSpots;
//               break;
//             case 'restaurants':
//               items = state.restaurants;
//               break;
//             case 'hotels':
//               items = state.hotels;
//               break;
//             default:
//               items = [];
//           }

//           if (items.isEmpty) {
//             return const Center(child: Text('No items found'));
//           }

//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: MasonryGridView.count(
//               crossAxisCount: 2,
//               mainAxisSpacing: 8.0,
//               crossAxisSpacing: 8.0,
//               itemCount: items.length,
//               itemBuilder: (context, index) {
//                 final item = items[index];
//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => DestinationPage(
//                           item: item, // Pass the destination item to the destination page
//                           type: type,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Card(
//                     child: Column(
//                       children: [
//                         Image.network(item.coverImage),
//                         Text(item.title),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         } else {
//           return const Center(child: Text('Failed to load destinations'));
//         }
//       },
//     );
//   }
// }
