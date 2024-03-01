import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class GalleryExampleItem {
  GalleryExampleItem({
    required this.id,
    required this.resource,
    this.isSvg = false,
  });

  final String id;
  final String resource;
  final bool isSvg;
  final ValueNotifier<bool> ignoringValue = ValueNotifier(false);
}

class GalleryExampleItemThumbnail extends StatelessWidget {
  const GalleryExampleItemThumbnail({
    Key? key,
    required this.galleryExampleItem,
    required this.onTap,
  }) : super(key: key);

  final GalleryExampleItem galleryExampleItem;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: GestureDetector(
        onTap: onTap,
        child: Hero(
          tag: galleryExampleItem.id,
          child: !galleryExampleItem.isSvg
              ? Image.asset(
                  galleryExampleItem.resource,
                  height: 80.0,
                  width: 200,
                  fit: BoxFit.fitWidth,
                )
              : SvgPicture.asset(
                  galleryExampleItem.resource,
                  height: 80.0,
                  fit: BoxFit.fitWidth,
                ),
        ),
      ),
    );
  }
}

List<GalleryExampleItem> galleryItems = <GalleryExampleItem>[
  GalleryExampleItem(
    id: "tag1",
    resource: "assets/gallery1.jpg",
  ),
  GalleryExampleItem(id: "tag2", resource: "assets/firefox.svg", isSvg: true),
  GalleryExampleItem(
    id: "tag5",
    resource: "assets/long1.jpg",
  ),
  GalleryExampleItem(
    id: "tag6",
    resource: "assets/long2.jpg",
  ),
  GalleryExampleItem(
    id: "tag3",
    resource: "assets/gallery2.jpg",
  ),
  GalleryExampleItem(
    id: "tag4",
    resource: "assets/gallery3.jpg",
  ),
];
