(function() {
    // 计算时间差
    function timeDiff(time){
        var diffdate = new Date().getTime() - time*1000;
        var days = Math.floor(diffdate/(24*3600*1000));
        var leave1 = diffdate%(24*3600*1000);   
        var hours = Math.floor(leave1/(3600*1000));  

        var leave2 = leave1%(3600*1000);
        var minutes = Math.floor(leave2/(60*1000));
        var leave3 = leave2%(60*1000);
        var seconds = Math.round(leave3/1000);
        return (days && days > 0) ? days + "天前" : (hours && hours > 0) ? hours + "小时前" : (minutes && minutes > 0) ? minutes + "分钟前" : "刚刚";
    }
    /*获取主题帖子详情*/
    function getForumThreadDetails(callback) {
        //TODO 实现native交互，获取主题帖子详情数据，并传给H5前端,由H5前端转换成 JSON.parse();
        var data=JSON.stringify({"follow":false,"recommend_add":10,"collection":false,"fid":37,"forumPic":"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=594559231,2167829292&fm=27&gp=0.jpg","summary":"近近景近景","forumName":"交友","subject":"标题标题标题标题标题标题标题标题标题标题","heats":0,"attachments":[{"fileName":"重力系统源码.rar","createdOn":148212731, "fileSize":39771,"readPerm":0, "isImage":0, "width":544, "uid":1,"url":"http://www.apkbus.com/201104/23/08053623ql625n0rz6s3d5.rar"},{"fileName":"我的照片","createdOn":148212731, "fileSize":39771,"readPerm":0, "isImage":1, "width":544, "uid":1,"url":"http://www.apkbus.com/201104/23/08053623ql625n0rz6s3d5.rar"} ],"avatar":"http://182.92.158.79/utf8_x33/uc_server/avatar.php?uid=190&size=middle","authorId":190,"createdOn":1493968050,"message":"<p>华叔说饭好少是粉红色的护发素的就俯拾地芥开发就是大回复就是导航福建省的和副驾驶的和副驾驶的合富金生店和副驾驶的和副驾驶的护发素的继父回家合富金生店和服就是的复活节</p><a href='www.baidu.com'>数据的撒地方惊世毒妃健身房附近的</a><p><img src='http://download.bbssdk.mob.com/bb0/160/d3e8d4488e23d31b99eabddbf2.jpg'><img src='http://img1.imgtn.bdimg.com/it/u=235569342,2055818743&fm=26&gp=0.jpg'></p>","author":"金城武","views":0,"replies":0,"images":["http://download.bbssdk.mob.com/30b/edb/ae9315c46ca6da0c8ea79ef0c5.jpg","http://download.bbssdk.mob.com/71f/c0e/62f88e0a1c1a015609dfdac044.jpg","http://download.bbssdk.mob.com/8d9/296/28016253bd6267a26dd8712037.png","http://download.bbssdk.mob.com/c61/bea/ff264d56027130de3d9ed3124c.jpg","http://download.bbssdk.mob.com/c61/bea/ff264d56027130de3d9ed3124c.jpg","http://download.bbssdk.mob.com/30b/edb/ae9315c46ca6da0c8ea79ef0c5.jpg","http://download.bbssdk.mob.com/f9d/26a/a39c9ad2d0539e124e4740b557.jpg"],"tid":234})
        callback(data);
    	
    }

    /*
     * 获取主题帖子回帖列表
     * @param authorId {number} 需要筛选的用户id，默认0（不筛选）
     * */
    function getPosts(fid, tid, page, pageSize,authorId, callback) {
        //TODO 实现native交互，获取主题帖子回帖列表数据，并传给H5前端,由H5前端转换成 JSON.parse();
        console.log(fid+"&&&"+tid+"&&&"+page+"&&&"+pageSize+"&&&"+authorId)
        var data=[{"author":"test_aa","avatar":"http:\/\/182.92.158.79\/utf8_x33\/uc_server\/avatar.php?uid=2469&size=middle","position":2,"authorId":2469,"deviceName":"iPhone 6s","message":"HK去搜婆婆log你","createdOn":1505103011,"fid":0,"tid":166516,"pid":260238},{"author":"test_aa","avatar":"http:\/\/182.92.158.79\/utf8_x33\/uc_server\/avatar.php?uid=2469&size=middle","position":3,"authorId":2469,"deviceName":"iPhone 6s","message":"\ning哦咯破<img src=\"http:\/\/download.bbssdk.mob.com\/2017\/09\/11\/12\/1505103029587.jpg\" border=\"0\" alt=\"\" \/>","createdOn":1505103030,"fid":0,"prePost":{"author":"test_aa","position":0,"authorId":0,"message":"HK去搜婆婆log你","createdOn":1505103000,"fid":0,"tid":0,"pid":0},"tid":166516,"pid":260239}]
       callback(data);
    }

	/*点击头像后，前往作者详情*/
    function openAuthor(authorId) {
        //TODO 实现native交互，跳转作者的界面
        console.log(authorId);
    }
    
    /*
     * 关注文章作者
     * @param flag {number} 0为关注，1为取消关注
     * */
    function followAuthor(authorId,flag,callback) {
        //TODO 实现native交互，关注文章作者，返回结果（Boolean）给h5前端
        console.log(authorId + "&&&&" + flag);
        callback(true)
    }
    
    /*
     * 喜欢文章
     * */
    function likeArticle(fid,tid,callback) {
        //TODO 实现native交互，喜欢文章，返回结果（Boolean）给h5前端
        console.log(fid+"&&&"+tid);
        callback(true)
    }
	
    /*打开图片*/
    function openImage(imgList,index) {
        //TODO 实现native交互，跳转打开图片的界面
        console.log(index)
		console.log(JSON.stringify(imgList, null,2))
    }

    /*打开附件*/
    function openAttachment(attachment) {
        //TODO 实现native交互，跳转打开附件的界面
        console.log(attachment);
    }

    /* 跳转链接 */
    function openHref(href) {
    	//TODO 实现native交互，跳转到链接：href
        console.log(href);
    }
    
    /* 下载图片，iimgList为界面所有的img标签对应的图片链接 */
    function downloadImages(imgList) {
        //TODO 由Native去实现下载图片，并通过showImage方法，将下载好的图片返回给h5进行显示
        console.log(JSON.stringify(imgList, null,2))
        showImage('5a79560af426f702bc8aa56896fde32e', 'http://download.bbssdk.mob.com/71f/c0e/62f88e0a1c1a015609dfdac044.jpg')
        showImage('74cbe2be4c9f1e32e2cee3961fdb8032', 'http://download.bbssdk.mob.com/bb0/160/d3e8d4488e23d31b99eabddbf2.jpg')
        showImage('e214d62568598cae227f834b30a693a3', 'http://download.bbssdk.mob.com/bb0/160/d3e8d4488e23d31b99eabddbf2.jpg')
    }
    
    /* 显示图片，替换imgUrl对应的img标签的src值为imgSrc，其中imgSrc为Native已经下载好的本地图片地址 */
    function showImage(imgUrlMD5, imgSrc) {
        //H5实现此方法，并进行图片替换操作
    	if (imgSrc) {
    		$("."+imgUrlMD5).attr("src",imgSrc)
			$("."+imgUrlMD5).attr("src_flag",'1')
    	} else{
    		$("."+imgUrlMD5).attr("src",'../assets/images/default_pic_error.png')
    	}
    }

    /* 
     * 添加新的评论
     * @param data {Object} 评论内容
     * @param authorId {number} 楼主编号
     * */
    function addNewCommentHtml(data, authorId){
        //TODO 实现native交互，添加新的评论
        var data={position:2,"message":"qweqweqweqweqweqwe","createdOn":1497579547,"author":"admin","deviceName":"PC","pid":259821,"tid":166365,"avatar":"http://182.92.158.79/utf8_x33/uc_server/avatar.php?uid=1&size=middle","authorId":1}
	        

        details.commentList.push(data)//将data插入即可
    }

    /* 
     * 回复方法 
     * @param prepost {Object} 回复内容
    */
    function replyComment(prepost){
    	//TODO 实现native交互，回复方法
        console.log(prepost);
        addNewCommentHtml()
    }

	/* 获取图片集合地址和当前索引 
    * 设置hideNav为true时不显示头
    */
    function getImageUrlsAndIndex(callback,hideNav) {
        //TODO 由Native返回对象{imageUrls:[], index:0}
        callback({imageUrls:["https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=949197531,2432970866&fm=23&gp=0.jpg",
        "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1738350124,1182499903&fm=23&gp=0.jpg",
        "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1497794588,1167065085&fm=23&gp=0.jpg"
        ], index:0});
        if(hideNav){
            $(".photo-browser .bar").hide();
            $(".bar-nav~.content").css({"top": "0"});
        }
    }
    
    /* 
     * 只看楼主
     * @param flag {number} 1为只看楼主，0为取消只看楼主
     * */
    function updateCommentHtml(flag){
    	$(document.body).scrollTop(0);
    	details.commentList=[]
    	if(flag==1){
    		details.onlyAuthor=true
    		details.authorId=details.article.authorId
    		details.getCommentList(details.article.fid, details.article.tid, 1, details.pageSize, details.authorId);
    	}
    	else{
    		details.onlyAuthor=false
    		details.authorId=0
    		details.getCommentList(details.article.fid, details.article.tid, 1, details.pageSize, details.authorId);
    	}
    }


    /**
     * press 回调
     * @param  {[type]} img [description]
     * @return {[type]}     [description]
     */
    function pressImgCallback(img){
        console.log(img);
    }


    /*设置当前页面图片地址和index*/
    function setCurrentImageSrc(imgSrc, index) {
        //TODO 由Native去实现图片界面切换后的界面状态
    }
    
    /*界面跳转到评论模块*/
    function goComment() {
        details.goComment()
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
        replyComment: replyComment,
        addNewCommentHtml: addNewCommentHtml,
        pressImgCallback: pressImgCallback,
        //2017-08-21新增接口
        updateCommentHtml: updateCommentHtml,
        openAuthor:openAuthor,
        followAuthor:followAuthor,
        likeArticle:likeArticle,
        //2017-08-23新增接口
        goComment:goComment
    }
})();