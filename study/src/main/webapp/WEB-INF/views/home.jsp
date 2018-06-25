<jsp:include page ="/WEB-INF/views/common/header.jsp"><jsp:param value="" name="pageTitle"/></jsp:include>
<div id="carouselExampleIndicators" class="carousel slide" data-ride="carousel">
  <ol class="carousel-indicators">
    <li data-target="#carouselExampleIndicators" data-slide-to="0" class="active"></li>
    <li data-target="#carouselExampleIndicators" data-slide-to="1"></li>
    <li data-target="#carouselExampleIndicators" data-slide-to="2"></li>
  </ol>
  <div class="carousel-inner">
    <div class="carousel-item active">
      <img class="d-block w-100" src="${rootPath }/resources/images/coding2.png" alt="First slide">
        <div class="carousel-caption d-none d-md-block">
	    <h5>test</h5>
	    <p>.afdsf.</p>
  	</div>
    </div>
    <div class="carousel-item">
      <img class="d-block w-100" src="${rootPath }/resources/images/coding3.jpg" alt="Second slide">
        <div class="carousel-caption d-none d-md-block">
	    <h5>.test1.</h5>
	    <p>asdfasdf..</p>
  </div>
    </div>
    <div class="carousel-item">
      <img class="d-block w-100" src="${rootPath }/resources/images/coding4.jpg" alt="Third slide">
	  <div class="carousel-caption d-none d-md-block">
	    <h5>test2..</h5>
	    <p>...</p>
  </div>      
    </div>
  </div>
  <a class="carousel-control-prev" href="#carouselExampleIndicators" role="button" data-slide="prev">
    <span class="carousel-control-prev-icon" aria-hidden="true"></span>
    <span class="sr-only">Previous</span>
  </a>
  <a class="carousel-control-next" href="#carouselExampleIndicators" role="button" data-slide="next">
    <span class="carousel-control-next-icon" aria-hidden="true"></span>
    <span class="sr-only">Next</span>
  </a>
</div>



<div id="container" class="container rm_study_list studies">
	<div id="content">
		<div class="clearfix">
			<div class="float-left">
				<h4>스터디</h4>
			</div>
			<button type="button" class="btn btn-secondary float-right">전체보기</button>
		</div>
		<ul class="list">
		</ul>
	</div>
</div>

<div id="container" class="container rm_study_list lectures">
	<div id="content">
	<h4>강의</h4>
		<ul class="list">
		</ul>
	</div>
</div>




<div class="container">

	<div>강의리스트</div>
	<div>스터디 그룹트 뭐가 그렇게 좋나요?</div>
	<div>누적 스터디 멤버 , 스터디 성사율, 누적 스터디/ 강의 개설수</div>
	<div>강사 신청하기</div>
</div>
<script>
$(function(){
	$('.carousel').carousel();
	
	$.ajax({
		url:"${rootPath}/rest/study/all/4",
		dataType:"json",
		success:function(data){
			console.log(data);
			$("input#total").val(data.total);
			$("input#numPerPage").val(data.numPerPage);
			$("input#cPageNo").val(data.cPage);
			var rmHtml = "";
			var study = null;
        	for(index in data.list){
        		study = data.list[index];
        		var upfile = (data.list[index].UPFILE);
        		if(upfile != undefined){
        			var study = data.list[index]; 
        			upfiles = upfile.split(",")[0];
	        		rmHtml += "<li class='col-md-4'>";
	        		rmHtml += "<div class='pixel'>";
	       			rmHtml += "<a href='${rootPath}/study/studyDetailView?sno="+study.SNO+"'>";
	   				rmHtml += "<div class='photoSection'>";
	   				rmHtml += 	"<div style='background-image:url(${rootPath}/resources/upload/study/"+upfiles+")'></div>";
	   				rmHtml += "</div>";
					rmHtml += "<div class='inforSection'>";
	  				rmHtml += 	"<h4>"+data.list[index].TITLE.substring(0, 20)+"</h4>";
	  				rmHtml += 	"<div class='profile'><img src='${rootPath}/resources/upload/study/20180625_215620103_62.gif' /></div>";
	  				
	   				rmHtml += "</div>";
					rmHtml += "<div class='metaSection'>";
	  				rmHtml += 	"<p></p>";
	   				rmHtml += "</div>";
	   				rmHtml += "</a>"
	        		rmHtml += "</div>"
	        		rmHtml += "</li>"
        		}
        	}
			$(".studies ul").html(rmHtml);
		},error:function(){
			
		}
	});
	
	
	
	
	$.ajax({
		url:"${rootPath}/rest/lecture/8",
		dataType:"json",
		success:function(data){
			var rmHtml = "";
        	for(index in data.list){
        		console.log(data.list[index].TNAME);
        		/* var upfile = (data.list[index].UPFILE); */
/*         		if(upfile != undefined){ */
        			/* upfiles = upfile.split(",")[0]; */
	        		rmHtml += "<li class='col-md-3'>";
	        		rmHtml += "<div class='pixel'>";
	       			rmHtml += "<a href=''>";
	   				rmHtml += "<div class='photoSection'>";
	   				rmHtml += 	"";
	   				rmHtml += "</div>";
					rmHtml += "<div class='inforSection'>";
	  				rmHtml += 	"<h4>"+data.list[index].KNAME+"</h4>";
	   				rmHtml += "</div>";
					rmHtml += "<div class='metaSection'>";
	  				rmHtml += 	"<p></p>";
	   				rmHtml += "</div>";
	   				rmHtml += "</a>"
	        		rmHtml += "</div>"
	        		rmHtml += "</li>"
/*         		} */
        	}
			$(".lectures ul").html(rmHtml);
		},error:function(){
			
		}
	});
})
</script>
<style>
.studies .inforSection::before{
position: absolute;
    top: -82px;
    left: 169px;
    content: "";
    display: block;
    width: 200px;
    height: 107px;
    background-position: center center;
    background-repeat: no-repeat;
    background-size: 156px auto;
    background-image: url(${rootPath}/resources/images/before.svg);
    clip: rect(-13px, 199px, 60px, 0px);
    z-index: 0;
}
</style>
<jsp:include page ="/WEB-INF/views/common/footer.jsp" />