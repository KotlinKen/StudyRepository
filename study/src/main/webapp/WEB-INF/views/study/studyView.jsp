<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
 <jsp:include page="/WEB-INF/views/common/header.jsp">
 	<jsp:param value="" name="pageTitle"/>
</jsp:include>	 
<style>
.notLeader{
	display:none;
}

div.sideInfo{

}
div#carouselExampleControls{
	width:500px;
	height:600px;
}
div.carousel-item img{
	width:500px;
	height:600px;
}
div.member-photo img{
	widht:60px;
	height:70px;
}
div.review-detail a{
	color:coral;
}
</style>

<script>
//참여신청 버튼 클릭 이벤트
function studyApply(sno){
	//세션에서 멤버의 mno 받아옴 로그인 안한상태에 대해서도 분기 처리.
	//이미 신청을 했으면 return;하게 만들어야 함. 
	//임시로 confirm. 계획은 부트스트랩 모달창에 주요 정보 나열 후 확인버튼누르면 아작스 실행.
	var mno=${memberLoggedIn!=null? memberLoggedIn.getMno():"0"};
	if(${memberLoggedIn!=null}){
	
		if(confirm("신청하시겠습니까")) {
			$.ajax({
				url:"applyStudy.do",
				data:{sno:sno,mno:mno},
				success:function(data){
					if(data==-1){
						alert("신청인원 최대 인원 100명을 넘었습니다.");
					}
					else if(data==0){
						alert("이미 신청한 스터디입니다.");
					}else{
						alert("신청되었습니다.");
					}
					//신청 완료 후 button에 스타일 주어서 이미 신청했음을 표시하게 한다.
				},error:function(){
					
				}
			});
		}
	}else{
		//alert("로그인 후 이용하세요");
		$("button#btn-login").trigger('click');
	}
	
}

//찜하기 버튼 클릭 이벤트
function studyWish(sno){
	//세션에서 멤버의 mno 받아옴 로그인 안한상태에 대해서도 분기 처리.
	//찜하기를 이미 선택했다면 다시 누르면 찜하기에서 삭제됨.
	var mno=${memberLoggedIn!=null? memberLoggedIn.getMno():"0"};
	if(${memberLoggedIn!=null}){//로그인을 한 상황
		
		if(${isWish==0}){//사용자는 전에 찜하지 않았음.
			$.ajax({
				url:"wishStudy.do",
				data:{sno:sno,mno:mno},
				success:function(data){
					console.log("찜했다");
					$("img.wish").attr("src","${pageContext.request.contextPath }/resources/upload/study/nowish.png");
					if(confirm("찜한 목록으로 가시겠습니까?")){
						location.href="${pageContext.request.contextPath}/member/memberWish.do?mno="+mno;
					}
				},error:function(){
					
				}
			});
		}else{
			if(confirm("이미 찜했습니다. 취소하겠습니까?")){
				$.ajax({
					url:"deletewishStudy.do",
					data:{sno:sno,mno:mno},
					success:function(data){
						$("img.wish").attr("src","${pageContext.request.contextPath }/resources/upload/study/wish.png");
					},error:function(){
						
					}
				});
			}
		}
	}else{//로그인창 띄움.
		$("button#btn-login").trigger('click');
	}
	
}
$(function(){
	
	$("button.editStudy").click(function(){
		location.href="studyUpdate.do?sno="+${study.SNO};
		
	});
	
	$("button.removeStudy").click(function(){
		if(confirm("정말 삭제하시겠습니까?")){
			location.href="deleteStudy.do?sno="+${study.SNO};

		}
	});
		
	
	
	
});


</script>
<div id="study-detail">
	<c:set var="imgs" value="${fn:split(study.UPFILE,',')}"/>
<c:if test="${memberLoggedIn!=null&&memberLoggedIn.getMno()==study.MNO}">
	<button type="button" class="editStudy">스터디 수정</button> <!-- 팀장일때만 나타날 것임. -->
	<button type="button" class="removeStudy">스터디 삭제</button><!-- 팀장일때만 나타날 것임. -->
</c:if>	


<!-- 사진 뷰 -->
<div id="carouselExampleControls" class="carousel slide" data-ride="carousel">
  <div class="carousel-inner">
	   <c:forEach var="img" items="${imgs }" varStatus="vs"> 
			<div class="carousel-item ${vs.first? 'active':'' }">
		     	<img class="d-block w-100" src="${pageContext.request.contextPath }/resources/upload/study/${img }" alt="Second slide">
		     </div> 
  		</c:forEach> 
  </div>
  
  <a class="carousel-control-prev" href="#carouselExampleControls" role="button" data-slide="prev">
    <span class="carousel-control-prev-icon" aria-hidden="true"></span>
    <span class="sr-only">Previous</span>
  </a>
  <a class="carousel-control-next" href="#carouselExampleControls" role="button" data-slide="next">
    <span class="carousel-control-next-icon" aria-hidden="true"></span>
    <span class="sr-only">Next</span>
  </a>
  
</div>
<!-- 사진 뷰 끝 -->


<span>LEVEL : ${study.DNAME }</span>
<span>${study.LNAME }-${study.TNAME }</span>
<span>${study.TITLE }</span>
<span>스터디 소개 : ${study.CONTENT }</span>
<div id="detail">
<span>지역 : ${study.LNAME }-${study.TNAME }</span>
<span>인원 : ${study.RECRUIT }명</span><br />
<span>
	${study.FREQ }
</span>
<span>${study.TIME }</span><br />
<span>신청기간 : ${study.LDATE }까지</span>
<span>수업 기간 : ${study.SDATE }~${study.EDATE }</span>
<span>협의비 : ${study.PRICE }</span>
<hr />
<label for="">리더 소개</label><br />
<c:if test="${study.MPROFILE!=null }">
<img src="${pageContext.request.contextPath}/resources/upload/member/${study.MPROFILE}" alt="" />
</c:if>
<c:if test="${study.MPROFILE==null }">
<img src="${pageContext.request.contextPath}/resources/upload/member/basicprofile.png" alt="" />
</c:if>

<span>${study.COVER }</span>

</div>


<div id="review-container"><!-- 팀장에 대한 후기 -->
<h5>리더에 대한 후기</h5>
<c:if test="${reviewList!=null }">
	<ul class="reviews">
		<c:forEach var="r" items="${reviewList }">
			<li class="review-one">
				<div class="member-photo">
					<img src="${pageContext.request.contextPath }/resources/upload/member/${r.MPROFILE!=null? r.MPROFILE:'basicprofile.png'}" alt="" />
				</div>
				<div class="review-detail">
					<span>${r.MNAME }</span>&nbsp;|&nbsp;<span>${r.POINT }점</span>
					<p>${r.CONTENT }</p>
					<a href="studyView.do?sno=${r.SNO }">${r.TITLE }</a><br />
					<span><fmt:formatDate value="${r.REGDATE }" pattern="yyyy-MM-dd"/></span>
				
					
				</div>
			</li>
		</c:forEach>
	</ul>

</c:if>
<c:if test="${reviewList==null }">
아직 평가가 없습니다.
</c:if>

</div>


</div>
<div id="side-info"> <!-- 오른쪽 fix창 -->
<span>${study.KNAME } : ${study.SUBNAME }</span>
<span>${study.TITLE }</span><br />
<span>${study.SDATE }~${study.EDATE }</span>
<button type="button" onclick="studyApply('${study.SNO}');"><span>참여신청하기</span></button>
<button type="button" onclick="studyWish('${study.SNO}');"><span>찜하기</span></button>


</div>


</section>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>	
