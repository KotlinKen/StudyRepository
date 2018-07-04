
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
<script
	src="${pageContext.request.contextPath }/resources/js/jquery-3.3.1.js"></script>
<!-- 부트스트랩관련 라이브러리 -->
<link rel="stylesheet"
	href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css"
	integrity="sha384-9gVQ4dYFwwWSjIDZnLEWnxCjeSWFphJiwGPXr1jddIhOegiu1FwO5qRGvFXOdJZ4"
	crossorigin="anonymous">
<script
	src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/js/bootstrap.min.js"
	integrity="sha384-uefMccjFJAIv6A+rW+L4AHf99KvxDjWSu1z9VI8SKNVmz4sk7buKt/6v9KI65qnm"
	crossorigin="anonymous"></script>
<script src="${rootPath}/resources/js/member/enroll.js"></script>
<link type="text/css"  rel="stylesheet" href="${rootPath}/resources/css/member/enroll.css" />
</head>
<body>
	
<div id="inindivik1"></div> 
<div id="inindivik2"><a id="headaik" href="${pageContext.request.contextPath}"><br /><h1>STUDY GROUPT</h1><br /></a></div>
	<div id="enroll-container">
		<form action="instructorEnrollEnd.do"
			method="post" name='mainForm' id='mainForm'
			onsubmit="return validate();" enctype="multipart/form-data">
			<div id="id-password-div-ik">
				<br />
				<!-- 아이디 -->
				<div id="userId-container">
					<input type="text" name="mid" id="userId_" placeholder="아이디(필수)" maxlength="15" required autocomplete="off" />
					<button type="button" onclick="fn_checkID();" class="btn btn-outline-secondary">아이디 확인</button>
					<br />
					<div id="check-id">
					<span class="guide ok"></span> 
					<span class="guide error"></span> 
					</div>
					<input type="hidden" id="idDuplicateCheck" value="0" />
				</div>
				<!-- 패스워드 -->
				<div>
					<input type="password" name="pwd" id="password_" placeholder="비밀번호(필수)"  maxlength="15" required autocomplete="off"  /> <br /> 
					<span id="pwd"></span>  
					<span id="pwdok"></span>  
					<input type="password" id="password2" placeholder="비밀번호 확인(필수)"  maxlength="15"  required autocomplete="off"  /> <br /> 
					<span id="pwd2"></span> 
					<span id="pwd2ok"></span> 
					<input type="hidden" id="pwdDuplicateCheck" value="0" />
				</div>
				<br />
				
			</div>
			<div id="name-phone-email-gender-div-ik">
			
			<!-- 이름 -->
			<input type="text" name="mname" id="name" placeholder="이름(필수)"  maxlength="7" required  autocomplete="off"  />
			<span id="nameerr" class="name"></span> 
			<span id="nameok" class="name"></span> <br /> 
			
			<!-- 전화번호 -->
			<input type="text" name="phone" id="phone" maxlength="11" placeholder="전화번호(필수)" required required autocomplete="off"  /> <br /> 
			<span id="phoneerr" class="phone"></span> <br />
			
			<!-- 이메일 -->
			<input type="text" name="email" id="email" placeholder="이메일(필수)" required  maxlength="15"  autocomplete="off"  /> @ 
			<input type="text" name="email" id="emailaddr" placeholder="직접입력" required  maxlength="20"  autocomplete="off"  />
			<input type="button" value="인증번호" onclick="fn_certification();" class="btn btn-outline-secondary"/> 
			<input type="hidden" id="checkcertification" value="0" /> 
			<input type="text" id="inputCode" placeholder="인증번호를 입력하세요" required autocomplete="off"/>
			<input type="button" value="확인" onclick="checkJoinCode();" class="btn btn-outline-secondary" /> 
			<input type="hidden" id="checkPoint" value="0" /> <br />
			
			<!-- 생년월일 -->
			<input type="date" name="birth" required/><br />
			<span class="jender">
			<input type="radio" name="gender" value="M" id="male" checked /> <label for="male">남</label> 
			</span>
			<span class="jender">
			<input type="radio" name="gender" value="F"id="fmale" /> <label for="fmale">여</label> <br /> 
			</span><br /><br />
			</div>
			<div class="blank-ik"></div>
			<br /><br />

			<!-- 사진 올리기 -->
			프로필사진(필수) : <input type="file" name="upFile" id="upFile" accept="image/*" /> 
			<input type='hidden' name='mprofile' id="mprofile" value='no' />
			<div id="div-img-ik"></div>
			<br />
			<br />
			
			<!-- 파일 올리기 -->
			포트폴리오(필수) : <input type="file" name="psFile" id="port" required  accept=".txt, .hwp, .docx , .pptx ,.ppt , xlsx ,.xls"/> <br /><br />
			자기소개서(필수) : <input type="file" name="psFile" id="self" required accept=".txt, .hwp, .docx , .pptx ,.ppt , xlsx ,.xls" /> <br />
			
			<!-- 카테고리 설정 -->
			<div class="form-check-inline form-check">
				<label for="kind">카테고리</label>
				<select name="kno" id="kind"> <!-- kind선택시 ajax로 그에 맞는 과목 가져오기 -->
					<option value="-1">과목을 선택하세요.</option>
					
					<c:if test="${!empty kindList }">
					<c:forEach var="kind" items="${kindList }" varStatus="vs">
						<option value="${kind.KNO }">${kind.KINDNAME }</option>
					</c:forEach>
					</c:if>
				</select>
				<select name="sno" id="sub"> <!-- ajax로 kind가져오기 -->
				
				</select>
			</div>

			<br />  <br />
			<textarea rows="10" cols="50" name="cover"placeholder="강사님 당신을 소개 하세요 모두가 알 수 있도록...(필수)" maxlength="1000" ></textarea>

			<br />
			<%-- <button type="button" onclick="location.href='${pageContext.request.contextPath}'">취소</button> --%>
			<input type="submit" id="submit" value="가입하기" class="btn btn-outline-secondary"/>
		</form>
		<br />
		<br />

	</div>
</body>
</html>