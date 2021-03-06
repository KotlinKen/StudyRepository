<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>${param.pageTitle}</title>
<script src="${pageContext.request.contextPath }/resources/js/jquery-3.3.1.js"></script>
<!-- 부트스트랩관련 라이브러리 -->
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css" integrity="sha384-9gVQ4dYFwwWSjIDZnLEWnxCjeSWFphJiwGPXr1jddIhOegiu1FwO5qRGvFXOdJZ4" crossorigin="anonymous">
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/js/bootstrap.min.js" integrity="sha384-uefMccjFJAIv6A+rW+L4AHf99KvxDjWSu1z9VI8SKNVmz4sk7buKt/6v9KI65qnm" crossorigin="anonymous"></script>
<!-- 사용자작성 css -->
<link rel="stylesheet" href="${pageContext.request.contextPath }/resources/css/style.css" />
<style>
p{width: 450px; height: 150px; overflow-y: scroll; margin: auto; background: white;border: 0.1px solid gray; padding: 5px}
#home{height: 100px; font-size: 35px;  background: rgb(255, 255, 255,0.001); display: block;}
div{width: 500px; min-height: 30px;margin: auto;  }
div#indivik{margin: auto; border-radius:5px;  }
div#inindivik1{ width: 100%;}
div#inindivik2{ width:100%;   text-align: center;}
div#inindivik3{width: 200px; margin: auto; text-align: left; }
div#headerdivik{ background: blue; width: 100%; }
span{position: relative; left: 20px;}
#buttona{position: relative; left: 20px;}
#buttonb{position: relative; left: 71%;}
input[type=checkbox], input[type=radio]{ width: 20px;height: 20px; border-radius :10px;}
#headaik{color: black;}
/* body{background: lightblue url("${rootPath}/resources/images/young.jpg") no-repeat fixed right; } */
#backbord{width:100%; height:100%;  background: #efefef;} 
hr { 
    display: block;
    margin-top: 0.5em;
    margin-bottom: 0.5em;
    margin-left: auto;
    margin-right: auto;
    border-style: inset;
    border-width: 1px;
    background : rgb(0, 0, 255);
} 
::-webkit-scrollbar {display:none;}
</style>
</head>
<body>
<div id="backbord">
<form name=frmSubmit>

<div id="inindivik1"></div>
<div id="background">

<div id="indivik">
<div id="inindivik2"><a class="navbar-brand rm-custom-brand" href="${rootPath}"><jsp:include page="/WEB-INF/views/common/logo_blue.jsp"></jsp:include></a></div>
		<div id="inindivik3"><input type="hidden" name="check" id="check" value="21" /></div> 
<span id="home"><b>회원가입</b></span>
		<span><input type="checkbox" class="agree" id="checkAll"  /> <b>전체 동의</b></span>	 <br />
		<br />
		<span><input type="checkbox" class="agree" id="agree1" value="0" name="agree1" /> <b>서비스 이용약관 동의 (필수) </b></span>		<br /><br />
		<p >
			<c:forEach var ="v" items="${service }">
				${v.SCONTENT } <br /><br />
			</c:forEach>
		</p>
		
		<br />
		<span><input type="checkbox" class="agree" id="agree2" value="0" name="agree2"  /> <b>개인정보 수집 및 이용 동의 (필수) </b></span> <br /><br />
		<p >
			<c:forEach var ="v" items="${information }">
				${v.ICONTENT } <br /><br />
			</c:forEach>
		</p>
		<br />
		<button type="button" id="buttona" class="btn btn-primary" onclick="location.href='${pageContext.request.contextPath}'">취소</button>
		<button type="button" id="buttonb" class="btn btn-primary" onclick="getPost(01);">다음</button> 
		<br /><br />
		<span>강사를 희망 하신다면 여기 <a href="#" onclick="getPost(02);" ><b>강사 신청하기</b></a>를 누르세요</span>
	<br /><br />
</div>
</div>
</form>
<br /><br />
<script>
	$("#agree1").click(function() {
		var chk1=document.getElementById("agree1");
		if(!chk1.checked){
			$("#agree1").val(0);
		}else{
			$("#agree1").val(1);
		}
	}); 
	$("#agree2").click(function() {
		var chk2=document.getElementById("agree2");
		if(!chk2.checked){
			$("#agree2").val(0);
		}else{
			$("#agree2").val(1);
		}
	}); 
	$("#checkAll").click(function () {
		var checkAll = $("#checkAll").prop("checked");
		if(checkAll ==true){
			var check = document.getElementsByClassName("agree");
			for(var i = 0; i<check.length;i++ ){
				if(check[i].checked == false){
					check[i].checked = true;
					$("#agree1").val(1);
					$("#agree2").val(1);
				}
			} 
		$("#buttonb").focus();
		}else{
			var check = document.getElementsByClassName("agree");
			for(var i = 0; i<check.length;i++ ){
				if(check[i].checked == true){
					check[i].checked = false;
					$("#agree1").val(0);
					$("#agree2").val(0);
				}
			} 
		}
		
	});
 	
 	function getPost(mode){
 		var chk1=document.getElementById("agree1");
        var chk2=document.getElementById("agree2");
       
        if(!chk1.checked){
            alert('서비스 이용에 동의해야 진행할 수  있습니다.');
            return;
        }
        if(!chk2.checked) {
            alert('개인정보 수짐에 동의해야 진행할 수  있습니다.');
            return;
        }
	 	var theForm = document.frmSubmit;
	 	if(mode == "01"){
	 	theForm.method = "post"; 
	 	theForm.target = "_self";
	 	theForm.action = "${pageContext.request.contextPath}/member/memberEnroll.do";
	 	} else if(mode == "02"){
	 	 	theForm.method = "post";
	 	 	theForm.target = "_self";
	 	 	theForm.action = "${pageContext.request.contextPath}/member/instructorEnroll.do"
	 	}
	 
	 	theForm.submit();
 	}
</script>
</div>
</body>
</html>
