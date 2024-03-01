import 'dart:async';

import 'package:day_demo/dismissible_page/lib/dismissible_page.dart';
import 'package:day_demo/screens/examples/gallery/quicker_scroll_physics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../common/app_bar.dart';
import 'gallery_example_item.dart';

class GalleryExample extends StatefulWidget {
  const GalleryExample({super.key});

  @override
  State createState() => _GalleryExampleState();
}

class _GalleryExampleState extends State<GalleryExample> {
  bool verticalGallery = false;

  @override
  Widget build(BuildContext context) {
    return ExampleAppBarLayout(
      title: "Gallery Example",
      showGoBack: true,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ...List.generate(
                      galleryItems.length,
                      (index) => GalleryExampleItemThumbnail(
                            galleryExampleItem: galleryItems[index],
                            onTap: () {
                              open(context, index);
                            },
                          )).toList(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Vertical"),
                Checkbox(
                  value: verticalGallery,
                  onChanged: (value) {
                    setState(() {
                      verticalGallery = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void open(BuildContext context, final int index) {
    context.pushTransparentRoute(GalleryPhotoViewWrapper(
      galleryItems: galleryItems,
      backgroundDecoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      initialIndex: index,
      scrollDirection: verticalGallery ? Axis.vertical : Axis.horizontal,
    ));
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => GalleryPhotoViewWrapper(
    //       galleryItems: galleryItems,
    //       backgroundDecoration: const BoxDecoration(
    //         color: Colors.black,
    //       ),
    //       initialIndex: index,
    //       scrollDirection: verticalGallery ? Axis.vertical : Axis.horizontal,
    //     ),
    //   ),
    // );
  }
}

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    super.key,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex = 0,
    required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<GalleryExampleItem> galleryItems;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  late int currentIndex = widget.initialIndex;
  void onPageChanged(int index) {
    for (var element in widget.galleryItems) {
      element.ignoringValue.value = false;
    }
    currentIndex = index;
  }

  bool ignoring = false;
  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      dragSensitivity: 1.0,
      onDismissed: () {
        Navigator.pop(context);
      },
      onDragUpdate: (d) {
        ignoring = d.offset != Offset.zero;
        final GalleryExampleItem item = widget.galleryItems[currentIndex];
        item.ignoringValue.value = ignoring;
      },
      direction: DismissiblePageDismissDirection.multi,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          // decoration: widget.backgroundDecoration,
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              PhotoViewGallery.builder(
                scrollPhysics: const QuickerScrollPhysics(),
                builder: _buildItem,
                wantKeepAlive: true,
                itemCount: widget.galleryItems.length,
                loadingBuilder: widget.loadingBuilder,
                backgroundDecoration: widget.backgroundDecoration,
                pageController: widget.pageController,
                onPageChanged: onPageChanged,
                scrollDirection: widget.scrollDirection,
              ),
              // Container(
              //   padding: const EdgeInsets.all(20.0),
              //   child: Text(
              //     "Image ${currentIndex + 1}",
              //     style: const TextStyle(
              //       color: Colors.white,
              //       fontSize: 17.0,
              //       decoration: null,
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final GalleryExampleItem item = widget.galleryItems[index];
    var child = PhotoViewGalleryPageOptions.customChild(
      child: ImageItemWidget(
        item: item,
        ignoringValue: item.ignoringValue,
        key: ValueKey(item.id),
      ),
      minScale: PhotoViewComputedScale.contained * 1.0,
      maxScale: PhotoViewComputedScale.covered * 4.1,
      heroAttributes: PhotoViewHeroAttributes(tag: item.id),
    );
    return item.isSvg
        ? PhotoViewGalleryPageOptions.customChild(
            child: SizedBox(
              width: 300,
              height: 300,
              child: SvgPicture.asset(
                item.resource,
                height: 200.0,
              ),
            ),
            childSize: const Size(300, 300),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
            maxScale: PhotoViewComputedScale.covered * 4.1,
            heroAttributes: PhotoViewHeroAttributes(tag: item.id),
          )
        : child;
    // : !(item.resource.contains('long'))
    //     ? child
    //     : PhotoViewGalleryPageOptions(
    //         imageProvider: AssetImage(item.resource),
    //         initialScale: PhotoViewComputedScale.contained,
    //         minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
    //         maxScale: PhotoViewComputedScale.covered * 4.1,
    //         heroAttributes: PhotoViewHeroAttributes(tag: item.id),
    //       );
  }
}

class ImageItemWidget extends StatefulWidget {
  const ImageItemWidget({
    super.key,
    required this.item,
    required this.ignoringValue,
  });
  final GalleryExampleItem item;
  final ValueNotifier<bool> ignoringValue;
  @override
  State<ImageItemWidget> createState() => _ImageItemWidgetState();
}

class _ImageItemWidgetState extends State<ImageItemWidget> {
  @override
  void initState() {
    // TODO: implement initState
    widget.ignoringValue.addListener(() {
      setStateSafe(() => null);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.ignoringValue.value) {
      return Container(
        alignment: Alignment.center,
        child: Scrollbar(
            child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            alignment: Alignment.center,
            child: Image.asset(
              widget.item.resource,
              fit: BoxFit.fitWidth,
              alignment: Alignment.center,
            ),
          ),
        )),
      );
    }
    return Container(
      alignment: Alignment.center,
      child: Scrollbar(
          child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          alignment: Alignment.center,
          child: Image.asset(
            widget.item.resource,
            fit: BoxFit.fitWidth,
            alignment: Alignment.center,
          ),
        ),
      )),
    );
  }
}

extension SafeSetStateExtension on State {
  FutureOr<void> setStateSafe(FutureOr<dynamic> Function() fn) async {
    await fn();
    if (mounted &&
        !context.debugDoingBuild &&
        context.owner?.debugBuilding != true) {
      if (context is Element) {
        bool defunct = (context as Element).debugIsDefunct;
        if (defunct) {
          return;
        }
      }
      // ignore: invalid_use_of_protected_member
      setState(() {});
    }
  }
}
