import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/entities/blog.dart';
import '../../../widgets/blog/detailed_blog_fullsize_image.dart';
import '../../../widgets/blog/detailed_blog_half_image.dart';
import '../../../widgets/blog/detailed_blog_quarter_image.dart';
import '../../../widgets/blog/detailed_blog_view.dart';
import '../models/list_blog_model.dart';
import '../../../generated/l10n.dart';


class BlogDetailScreen extends StatefulWidget {
  final Blog blog;

  BlogDetailScreen({required this.blog});

  @override
  _BlogDetailScreenState createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  PageController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final model = Provider.of<ListBlogModel>(context, listen: false);

    return Scaffold(
      appBar: !kIsWeb
          ? AppBar(
        backgroundColor: kColorSpiderRed,
        elevation: 0.1,
        title: Text(
          S.of(context).blog,
          style: const TextStyle(color: Colors.white),
        ),
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
        ),
      )
          : null,
      body: Consumer<ListBlogModel>(builder: (context, model, child) {
        final listBlog = model.blogs!;
        controller ??= PageController(initialPage: listBlog.indexOf(widget.blog));
        return PageView.builder(
          itemCount: listBlog.length,
          controller: controller,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            return getDetailScreen(listBlog[index]);
          },
        );
      }),
    );
  }

  Widget getDetailScreen(Blog blog) {
    if (Videos.getVideoLink(blog.content!) != null) {
      return OneQuarterImageType(item: blog);
    } else {
      switch (kAdvanceConfig['DetailedBlogLayout']) {
        case kBlogLayout.halfSizeImageType:
          return HalfImageType(item: blog);
        case kBlogLayout.fullSizeImageType:
          return FullImageType(item: blog);
        case kBlogLayout.oneQuarterImageType:
          return OneQuarterImageType(item: blog);
        default:
          return BlogDetail(item: blog);
      }
    }
  }
}
