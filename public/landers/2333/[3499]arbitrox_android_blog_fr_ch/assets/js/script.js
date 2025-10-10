document.addEventListener("DOMContentLoaded", function () {
  const elements = document.querySelectorAll(".fade-in");
  elements.forEach((el) => {
    el.classList.add("visible");
  });

  const articleLikeBtns = document.querySelectorAll(".article-like-btn");

  if (articleLikeBtns.length > 0) {
    let articleLikes = localStorage.getItem("articleLikeCount")
      ? parseInt(localStorage.getItem("articleLikeCount"))
      : parseInt(
          articleLikeBtns[0].querySelector(".article-like-count").textContent
        ) || 0;

    let articleLiked = localStorage.getItem("articleLiked") === "true";

    articleLikeBtns.forEach((btn) => {
      const likeIcon = btn.querySelector(".article-like-icon");
      const likeCountSpan = btn.querySelector(".article-like-count");

      likeCountSpan.textContent = articleLikes;

      if (articleLiked) {
        btn.classList.add("liked");
        likeIcon.src =
          "/landers/2333/[3499]arbitrox_android_blog_fr_ch/assets/images/svg/liked.svg";
      }

      btn.addEventListener("click", function () {
        if (!articleLiked) {
          articleLikes++;
          articleLiked = true;
        } else {
          articleLikes--;
          articleLiked = false;
        }

        localStorage.setItem("articleLikeCount", articleLikes);
        localStorage.setItem("articleLiked", articleLiked);

        articleLikeBtns.forEach((b) => {
          const icon = b.querySelector(".article-like-icon");
          const countSpan = b.querySelector(".article-like-count");

          countSpan.textContent = articleLikes;

          if (articleLiked) {
            b.classList.add("liked");
            icon.src =
              "/landers/2333/[3499]arbitrox_android_blog_fr_ch/assets/images/svg/liked.svg";
          } else {
            b.classList.remove("liked");
            icon.src =
              "/landers/2333/[3499]arbitrox_android_blog_fr_ch/assets/images/svg/like.svg";
          }
        });
      });
    });
  }

  const comments = document.querySelectorAll(".comment");

  comments.forEach((comment) => {
    const commentId = comment.getAttribute("data-id");
    const likeBtn = comment.querySelector(".like-btn");
    const likeCountSpan = comment.querySelector(".like-count");
    const likeIcon = comment.querySelector(".like-icon");

    if (!likeBtn || !likeCountSpan || !likeIcon) return;

    let likes = localStorage.getItem(`likeCount-${commentId}`)
      ? parseInt(localStorage.getItem(`likeCount-${commentId}`))
      : parseInt(likeCountSpan.textContent) || 0;

    let liked = localStorage.getItem(`liked-${commentId}`) === "true";

    likeCountSpan.textContent = likes;

    if (liked) {
      likeBtn.classList.add("liked");
      likeIcon.src =
        "/landers/2333/[3499]arbitrox_android_blog_fr_ch/assets/images/svg/liked.svg";
    }

    likeBtn.addEventListener("click", function () {
      if (!liked) {
        likes++;
        liked = true;
      } else {
        likes--;
        liked = false;
      }

      likeCountSpan.textContent = likes;

      localStorage.setItem(`likeCount-${commentId}`, likes);
      localStorage.setItem(`liked-${commentId}`, liked);

      if (liked) {
        likeBtn.classList.add("liked");
        likeIcon.src =
          "/landers/2333/[3499]arbitrox_android_blog_fr_ch/assets/images/svg/liked.svg";
      } else {
        likeBtn.classList.remove("liked");
        likeIcon.src =
          "/landers/2333/[3499]arbitrox_android_blog_fr_ch/assets/images/svg/like.svg";
      }
    });
  });
});
