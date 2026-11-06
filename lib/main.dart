import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/app_info.dart';
import 'providers/apps_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: OnePlusIOS27LauncherApp(),
    ),
  );
}

class OnePlusIOS27LauncherApp extends StatelessWidget {
  const OnePlusIOS27LauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnePlus iOS27 Launcher',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
      ),
      home: const LauncherHomeScreen(),
    );
  }
}

class LauncherHomeScreen extends ConsumerWidget {
  const LauncherHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsState = ref.watch(appsProvider);
    final appsNotifier = ref.read(appsProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search / Spotlight bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  onChanged: appsNotifier.setSearchQuery,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    hintText: 'Search Apps & Library...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // App list / grid area
            Expanded(
              child: appsState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : appsState.errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Failed to load apps: ${appsState.errorMessage}',
                                style: const TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => appsNotifier.loadApps(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => appsNotifier.loadApps(),
                          child: appsState.filteredApps.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No applications found',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 18,
                                    crossAxisSpacing: 14,
                                    childAspectRatio: 0.76,
                                  ),
                                  itemCount: appsState.filteredApps.length,
                                  itemBuilder: (context, index) {
                                    final app = appsState.filteredApps[index];
                                    return AppGridItem(
                                      app: app,
                                      onTap: () async {
                                        final success = await appsNotifier.launchApp(app);
                                        if (!success && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Could not launch ${app.appName}'),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppGridItem extends StatelessWidget {
  final AppInfo app;
  final VoidCallback onTap;

  const AppGridItem({
    super.key,
    required this.app,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // iOS squircle app icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: app.iconBytes != null
                ? Image.memory(
                    app.iconBytes!,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.android, color: Colors.white70, size: 32),
          ),
          const SizedBox(height: 6),
          // App Title
          Text(
            app.appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
