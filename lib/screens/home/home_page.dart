// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<String> _categories = [
    'Inicio',
    'Películas',
    'Series',
    'Deportes',
    'Noticias',
  ];

  final List<Map<String, String>> _featuredContent = [
    {
      'title': 'Película Destacada 1',
      'subtitle': 'Acción • 2024',
    },
    {
      'title': 'Serie Popular 1',
      'subtitle': 'Drama • Temporada 3',
    },
    {
      'title': 'Documental Nuevo',
      'subtitle': 'Naturaleza • 2024',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.backgroundDark,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: PlatformUtils.isTV ? null : _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ColorManager.backgroundDark,
      elevation: 0,
      title: Row(
        children: [
          Icon(
            PlatformUtils.isTV ? Icons.tv : Icons.movie,
            color: ColorManager.primary,
            size: 28,
          ),
          const SizedBox(width: AppSize.s12),
          Text(
            'ScrollTV',
            style: TextStyle(
              color: ColorManager.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: ColorManager.white,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.person,
            color: ColorManager.white,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: AppSize.s8),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categorías horizontales
          if (PlatformUtils.isTV) _buildTVCategories(),

          // Contenido destacado
          _buildFeaturedSection(),

          // Secciones de contenido
          _buildContentSection('Continuar viendo'),
          _buildContentSection('Recomendado para ti'),
          _buildContentSection('Tendencias'),

          const SizedBox(height: AppSize.s80), // Espacio para bottom nav
        ],
      ),
    );
  }

  Widget _buildTVCategories() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: AppMargin.m16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedIndex;
          return Container(
            margin: const EdgeInsets.only(right: AppMargin.m12),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? ColorManager.primary
                    : ColorManager.containerDarkBackground,
                foregroundColor: ColorManager.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p24,
                  vertical: AppPadding.p12,
                ),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Container(
      height: PlatformUtils.isTV ? 300 : 250,
      margin: const EdgeInsets.symmetric(vertical: AppMargin.m16),
      child: PageView.builder(
        itemCount: _featuredContent.length,
        itemBuilder: (context, index) {
          final content = _featuredContent[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppMargin.m16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Imagen de fondo (placeholder)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorManager.primary.withOpacity(0.8),
                          ColorManager.primaryDark.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.movie,
                      size: 80,
                      color: ColorManager.white.withOpacity(0.3),
                    ),
                  ),
                  // Contenido
                  Positioned(
                    bottom: AppPadding.p24,
                    left: AppPadding.p24,
                    right: AppPadding.p24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          content['title']!,
                          style: TextStyle(
                            color: ColorManager.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSize.s8),
                        Text(
                          content['subtitle']!,
                          style: TextStyle(
                            color: ColorManager.lightHintColorText,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppSize.s16),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.play_arrow),
                              label: Text('Reproducir'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorManager.primary,
                                foregroundColor: ColorManager.white,
                              ),
                            ),
                            const SizedBox(width: AppSize.s12),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.info_outline),
                              label: Text('Más info'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ColorManager.white,
                                side: BorderSide(color: ColorManager.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p16,
            vertical: AppPadding.p8,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: ColorManager.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: AppMargin.m12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: ColorManager.containerDarkBackground,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              ColorManager.primary.withOpacity(0.6),
                              ColorManager.primaryDark.withOpacity(0.6),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.movie,
                            color: ColorManager.white.withOpacity(0.7),
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppPadding.p8),
                      child: Text(
                        'Contenido ${index + 1}',
                        style: TextStyle(
                          color: ColorManager.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSize.s24),
      ],
    );
  }

  Widget? _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: ColorManager.containerDarkBackground,
      selectedItemColor: ColorManager.primary,
      unselectedItemColor: ColorManager.grey2,
      currentIndex: 0,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Buscar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.download),
          label: 'Descargas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
      onTap: (index) {},
    );
  }
}
