import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dharma_app/views/friends_screen.dart';
import 'package:dharma_app/views/my_choices.dart';
import 'package:dharma_app/views/profile_screen.dart';
import 'package:dharma_app/views/shop_now_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/home_controller.dart';
import '../controllers/usercontroller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final HomeController controller = Get.find();
  final UserController userController = Get.find();

  late final AnimationController _animController;
  late Animation<double> progressAnim;

  // small flag to show shimmer for top hero while profile completion animates
  final RxBool _showHeroShimmer = true.obs;

  @override
  void initState() {
    super.initState();

    _animController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1200));
    progressAnim = Tween<double>(begin: 0.0, end: 0.1).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    // Animate profile completion after a tiny delay
    Future.delayed(const Duration(milliseconds: 400), () {
      double progress = userController.profileCompletion;
      if (progress < 0.1) progress = 0.1;
      progressAnim = Tween<double>(begin: 0.0, end: progress).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOut));
      _animController.forward();
      _showHeroShimmer.value = false;
    });

    // when homeLayout changes -> pre-cache images
    ever(controller.homeLayout, (_) {
      _precacheLayoutImages();
    });
  }

  // Pre-cache all important images so list scrolls smoothly
  Future<void> _precacheLayoutImages() async {
    try {
      final layout = controller.homeLayout.value.homeLayout;
      final List<String> urls = [];

      // collect banner images
      if (layout.latestProductBanner != null) {
        for (var b in layout.latestProductBanner) {
          final u = (b?.imageInput ?? b?.imageInput) as String?;
          if (u != null && u.isNotEmpty) urls.add(u);
        }
      }

      // collect category thumbnails
      for (final cat in controller.filteredCategories) {
        final u = cat.image as String?;
        if (u != null && u.isNotEmpty) urls.add(u);
      }

      // dedupe
      final uniqueUrls = urls.toSet().toList();

      // precache with CachedNetworkImageProvider
      for (final url in uniqueUrls) {
        try {
          await precacheImage(CachedNetworkImageProvider(url), context);
        } catch (_) {
          // ignore single failures
        }
      }
    } catch (_) {
      // ignore
    }
  }


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Obx(() => RefreshIndicator(
          onRefresh: controller.fetchAllData,
          color: Colors.deepPurple,
          child: controller.isLoading.value ? _buildShimmer() : _buildContent(),
        )),
      ),
    );
  }

  Widget _buildContent() {
    final layout = controller.homeLayout.value.homeLayout;
    final userName =
        userController.user.value?.username?.split(' ').first ?? "Champion";

    return ListView(
      padding: const EdgeInsets.only(top: 20, bottom: 120),
      children: [
        // Hero
        Obx(() => _showHeroShimmer.value
            ? HeroCardShimmer()
            : HeroCard(
          userName: userName,
          progressAnim: progressAnim,
        )),

        const SizedBox(height: 30),

        // Search
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _SearchBox(),
        ),

        const SizedBox(height: 25),

        // Trending
        _sectionHeader("🔥 Trending Now"),
        TrendingBanners(items: layout.latestProductBanner ?? []),

        const SizedBox(height: 30),

        // Categories
        _sectionHeader("📁 Popular Categories"),
        SizedBox(height: 320, child: PopularCategorySlider()),


        const SizedBox(height: 40),
      ],
    );
  }

  // ---------------- UI atoms ----------------

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child:
      Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildShimmer() {
    // page-level shimmer (small, unobtrusive)
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      children: const [
        HeroCardShimmer(),
        SizedBox(height: 24),
        _ShimmerBannerStrip(),
        SizedBox(height: 24),
        _ShimmerCategoryGrid(),
      ],
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}

// ---------------------- HERO CARD (real) ----------------------
class HeroCard extends StatelessWidget {
  final String userName;
  final Animation<double> progressAnim;
  const HeroCard({required this.userName, required this.progressAnim, Key? key})
      : super(key: key);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning 👋";
    if (hour < 17) return "Good Afternoon ☀️";
    return "Good Evening 🌙";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 25, offset: Offset(0, 12))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.deepPurple.shade50,
                  child: const Icon(Icons.fitness_center, color: Colors.deepPurple, size: 36),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getGreeting(), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text("Hey $userName 👑", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      const Text("Ready to crush it today?", style: TextStyle(fontSize: 15, color: Colors.black54)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 350),
                      pageBuilder: (_, __, ___) => ProfileScreen(),
                      transitionsBuilder: (_, animation, __, child) {
                        final offset = Tween(begin: Offset(1, 0), end: Offset.zero)
                            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

                        return SlideTransition(position: offset, child: child);
                      },
                    ));

                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.deepPurple,
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            AnimatedBuilder(
              animation: progressAnim,
              builder: (_, __) => Column(
                children: [
                  SizedBox(
                    height: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressAnim.value,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("${(progressAnim.value * 100).round()}% Profile Completed", style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),

            const SizedBox(height: 18),
            ElevatedButton(

              onPressed: (){
                Navigator.push(context, PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 350),
                  pageBuilder: (_, __, ___) => StartWorkoutScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    final offset = Tween(begin: Offset(1, 0), end: Offset.zero)
                        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

                    return SlideTransition(position: offset, child: child);
                  },
                ));

              },
              child: const Text("Today choice 💪"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- HERO SHIMMER ----------------------
class HeroCardShimmer extends StatelessWidget {
  const HeroCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 25, offset: Offset(0, 12))],
          ),
        ),
      ),
    );
  }
}

// ---------------------- SEARCH BOX ----------------------
class _SearchBox extends StatelessWidget {
  const _SearchBox({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      placeholder: "Search workouts, trainers, supplements...",
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );
  }
}

// ---------------------- TRENDING BANNERS ----------------------
class TrendingBanners extends StatelessWidget {
  final List<dynamic> items;
  const TrendingBanners({required this.items, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();
    return SizedBox(
      height: 210,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final item = items[i];
          final String imageUrl = (item?.imageInput ?? item?.image) ?? "";
          return TrendingBannerItem(imageUrl: imageUrl);
        },
      ),
    );
  }
}
class TrendingBannerItem extends StatelessWidget {
  final String imageUrl;
  const TrendingBannerItem({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 350),
          pageBuilder: (_, __, ___) => ShopAllScreen(),
          transitionsBuilder: (_, animation, __, child) {
            final offset = Tween(begin: Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

            return SlideTransition(position: offset, child: child);
          },
        ));

      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 320,
          fit: BoxFit.cover,
          memCacheHeight: 420,
          memCacheWidth: 720,
          placeholder: (ctx, url) => _bannerPlaceholder(),
          errorWidget: (ctx, url, err) => _bannerError(),
        ),
      ),
    );
  }
}


  Widget _bannerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(color: Colors.white),
    );
  }

  Widget _bannerError() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.error_outline, color: Colors.red)),
    );
  }


// Shimmer strip for loading
class _ShimmerBannerStrip extends StatelessWidget {
  const _ShimmerBannerStrip({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, __) => ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(width: 320, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ---------------------- CATEGORY GRID ----------------------
class CategoryGrid extends StatelessWidget {
  CategoryGrid({Key? key}) : super(key: key);
  final HomeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cats = controller.filteredCategories;
      if (cats.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: Text("No categories found")),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.92,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (_, i) => CategoryTile(cat: cats[i]),
        ),
      );
    });
  }
}class CategoryTile extends StatelessWidget {
  final dynamic cat;
  const CategoryTile({required this.cat, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = cat.title ?? "Category";
    final image = cat.image ?? "";

    final screenWidth = MediaQuery.of(context).size.width;

    // 🔥 Responsive card height (auto adjusts)
    final double cardHeight = screenWidth * 0.70;   // Bigger card
    final double titleFont = screenWidth * 0.075;   // 26–30px depending on phone
    final double subFont = screenWidth * 0.035;     // 13–15px

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 350),
            pageBuilder: (_, __, ___) => ShopAllScreen(),
            transitionsBuilder: (_, animation, __, child) {
              final offset = Tween(begin: Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
              return SlideTransition(position: offset, child: child);
            },
          ),
        );
      },
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            /// BACKGROUND IMAGE (Larger + Responsive)
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: cardHeight,
                memCacheWidth: 900,
                memCacheHeight: 900,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                ),
              ),
            ),

            /// DARK GRADIENT OVERLAY
            Container(
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            /// TEXT CONTENT
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFont,  // 🔥 Responsive title
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "View More →",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: subFont,  // 🔥 Responsive subtitle
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class PopularCategorySlider extends StatelessWidget {
  final HomeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final cats = controller.filteredCategories;

    if (cats.isEmpty) {
      return const Center(child: Text("No categories found"));
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      itemCount: cats.length,
      itemBuilder: (_, i) {
        return Padding(
          padding: EdgeInsets.only(right: 18),
          child: CategoryBigCard(cat: cats[i]),
        );
      },
    );
  }
}
class CategoryBigCard extends StatelessWidget {
  final dynamic cat;
  const CategoryBigCard({required this.cat, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = cat.title ?? "Category";
    final image = cat.image ?? "";

    final screenWidth = MediaQuery.of(context).size.width;

    final double cardWidth = screenWidth * 0.70;  // 🔥 Large card
    final double cardHeight = screenWidth * 0.90; // 🔥 Taller card
    final double titleFont = screenWidth * 0.08;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ShopAllScreen()));
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 30,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: CachedNetworkImage(
                imageUrl: image,
                width: cardWidth,
                height: cardHeight,
                fit: BoxFit.cover,
                memCacheWidth: 1200,
                memCacheHeight: 1200,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(color: Colors.white),
                ),
              ),
            ),

            /// GRADIENT OVERLAY
            Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.65),
                    Colors.transparent
                  ],
                ),
              ),
            ),

            /// TEXT CONTENT
            Positioned(
              bottom: 25,
              left: 22,
              right: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFont,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "View More →",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: screenWidth * 0.04,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


// ---------------------- SHIMMER CATEGORY GRID ----------------------
class _ShimmerCategoryGrid extends StatelessWidget {
  const _ShimmerCategoryGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.92,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (_, __) => ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
