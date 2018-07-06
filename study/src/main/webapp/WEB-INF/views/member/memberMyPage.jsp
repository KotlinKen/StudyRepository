<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<style>
	li.btn-page{
		border-top: 1px solid #e1e1e1;
		border-bottom: 1px solid transparent;
		border-left: 1px solid #e1e1e1;
		border-right: 1px solid #e1e1e1;
		padding: 7px;
		border-radius: 10%;
		margin: 0;
		display: inline;
		background: #f9f9f9;
	}
	li.btn-page a{
		color: #666;
	}
</style>
<br />
<div class="ulpage">
<ul id="ul-page">
	<li class='btn-page'>
		<a href="${rootPath }/member/memberView.do" >개인정보</a>
	</li>
	<li class='btn-page'>
		<a href="${rootPath }/member/searchMyPageKwd.do?myPage=study">내 스터디/강의</a>
	</li>
	<li class='btn-page'>
		<a href="${rootPath }/member/searchMyPageKwd.do?myPage=apply">스터디 신청 목록</a>
	</li>
	<li class='btn-page'>
		<a href="${rootPath }/member/searchMyPageKwd.do?myPage=wish">스터디 관심 목록</a>
	</li>
	<li class='btn-page' id="insetruct">
		<a href="#" onclick="javascript:document.myForm.submit();" >강사신청</a>
	</li>
	<li class='btn-page'>
		<a href="${rootPath }/member/searchMyPageEvaluation.do" >평가 관리</a>
	</li>
</ul>
	
	
		<form name="myForm" action="${rootPath }/member/instructorApply.do" method="post" >
		<input type="hidden" name="mid" value="${memberLoggedIn.mid }" />
		<input type="hidden" name="mno" value="${memberLoggedIn.mno }" />
		</form>
</div>








<!-- 장익순 작업 시작 -->
<script>
$(document).ready(function(){
	console.log("?")
	instruct( ${memberLoggedIn.mno } );
});
function instruct(mno) {
	console.log(mno)
	$.ajax({
		url : "instructerCheckO.do",
		data : {"mno": mno},
		type : "POST",
		dataType : "json",
		success : function(date) {
			console.log("data="+date.stack)
			if(date.stack == false){
				console.log("m.m")
				$("#insetruct").hide();
			}
		},
		error : function(jqxhr, textStatus,errorThrown) {
			console.log(jqxhr);
			console.log(textStatus);
			console.log(errorThrown);
		}
	});
}
</script>
<!-- 장익순 작업  끝-->