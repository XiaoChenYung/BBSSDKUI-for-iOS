(function() {
    /*获取主题帖子详情*/
    function getForumThreadDetails(callback) {
        //TODO 实现native交互，获取主题帖子详情数据，并转成JSON对象
        $mob.ext.getForumThreadDetails(callback);
    }

    /*获取主题帖子回帖列表*/
    function getPosts(fid, tid, page, pageSize, callback) {
        //TODO 实现native交互，获取主题帖子回帖列表数据，并转成JSON对象
        $mob.ext.getPosts(fid, tid, page, pageSize, callback);
    }

    /*打开图片*/
    function openImage(imgList,index) {
        //TODO 实现native交互，跳转打开图片的界面
        $mob.native.openImage(imgList, index);
    }

    /*打开附件*/
    function openAttachment(attachment) {
        //TODO 实现native交互，跳转打开附件的界面
        $mob.native.openAttachment(attachment);
    }

    /* 跳转链接 */
    function openHref(href) {
        $mob.native.openHref(href);
    }

    /* 获取图片集合地址和当前索引 */
    function getImageUrlsAndIndex(callback) {
        //TODO 由Native返回对象{imageUrls:[], index:0}
        $mob.ext.getImageUrlsAndIndex(callback);
    }

    /*设置当前页面图片地址和index*/
    function setCurrentImageSrc(imgSrc, index) {
        //TODO 由Native去实现图片界面切换后的界面状态
        $mob.native.setCurrentImageSrc(imgSrc, index);
    }

    /* 下载图片，imgUrlList为界面所有的img标签对应的图片链接 */
    function downloadImages(imgUrlList) {
        //TODO 由Native去实现下载图片，并通过showImage方法，将下载好的图片返回给h5进行显示
        $mob.native.downloadImages(imgUrlList);

    }

    /* 显示图片，替换imgUrl对应的img标签的src值为imgSrc，其中imgSrc为Native已经下载好的本地图片地址 */
    function showImage(index, imgUrlMD5, imgSrc, isImageViewer) {
        //TODO H5实现此方法，并进行图片替换操作

        if (isImageViewer) {
            if (imgSrc) {
                $(".photo-browser .photo-browser-swiper-container .swiper-slide").eq(index).find("img").attr("src", imgSrc);
            } else {
                $(".photo-browser .photo-browser-swiper-container .swiper-slide").eq(index).find("img").attr("src", "img/default_pic_error.png");
            }
        } else {
            $.each($("[dz-imgshow]"), function(index, item){
                if (item.src_link == imgUrlMD5) {
                    if (imgSrc) {
                        item.src = imgSrc;
                    } else {
                        item.src = "img/default_pic_error.png";
                    }
                }
            });
        }
    }

    /*定义BBSSDKNative全局属性*/
    window.BBSSDKNative = {
        getForumThreadDetails: getForumThreadDetails,
        getPosts: getPosts,
        openImage: openImage,
        openAttachment: openAttachment,
        openHref: openHref,
        getImageUrlsAndIndex: getImageUrlsAndIndex,
        setCurrentImageSrc: setCurrentImageSrc,
        downloadImages: downloadImages,
        showImage: showImage,
    }
})();
