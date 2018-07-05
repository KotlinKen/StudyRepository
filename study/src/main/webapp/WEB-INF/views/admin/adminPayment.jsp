<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/common/admin_header.jsp">
<jsp:param value="PAYMENT" name="pageTitle" />
</jsp:include>

<script>
$(function(){
	var key = [];
	loadPay(1, 5, key);
});// $(function(){});

function loadPay(cPage, pageBarSize, key){	
	$.ajax({
		url:"${rootPath}/lecture/pay/"+cPage+"/"+pageBarSize+"/key",
		dataType:"json",
		success:function(data){
			
			var numPerPage = data.numPerPage;
			var cPage = data.cPage;
			var total = data.total;
			var totalPage = Math.ceil(parseFloat(total)/numPerPage);
			var pageNo = (Math.floor((cPage - 1)/parseFloat(pageBarSize))) * pageBarSize +1;
			var pageEnd = pageNo + pageBarSize - 1;
			var pageNation ="";
			
			$pagination = $(".pagination");
			
			if(pageNo == 1 ){
				pageNation += '<li class="page-item disabled"><a class="page-link" href="#">Previous</a></li>';
			}else{
				pageNation += '<li class="page-item"><a class="page-link" href="javascript:loadPay('+(pageNo-1)+','+5+')">Previous</a></li>';
			}
			while(!(pageNo > pageEnd || pageNo > totalPage)){
				pageNation += '<li class="page-item"><a class="page-link '+ ( pageNo == cPage ? "currentPage" : "" )+'" href="javascript:loadPay('+pageNo+','+5+')">'+pageNo+'</a></li>';
				pageNo++;
			}
			//다음 버튼
			
			if(pageNo > totalPage){
				pageNation += '<li class="page-item disabled"><a class="page-link" href="#">Next</a></li>';
			}else{
				pageNation += '<li class="page-item"><a class="page-link" href="javascript:loadPay('+pageNo+','+5+','+')">Next</a></li>';
			}
			
			//페이지 버튼 생성
			$pagination.html(pageNation);
			
			var rmHtml = "";
			var lecture = null;
			
	    	for(index in data.list){
	    		pay = data.list[index];
	    		
    			rmHtml += "<tr>"
    				rmHtml += "<td>" + pay.PNO + "</td>";
    				rmHtml += "<td>" + pay.TITLE + "</td>";
    				rmHtml += "<td>" + pay.MNAME + "</td>";
    				rmHtml += "<td>" + pay.REGDATE + "</td>";    				
    				rmHtml += "<td>" + pay.SDATE + "</td>";
    				rmHtml += "<td>" + pay.FREQ + "</td>";
    				rmHtml += "<td>" + pay.TIME + "</td>";
    				rmHtml += "<td>" + pay.PRICE + "</td>";
    				rmHtml += "<td>" + pay.CNT + "</td>";
    				rmHtml += "<td>" + pay.RECRUIT + "</td>";
    				rmHtml += "<td>" + pay.LOCAL + "/" + pay.TOWNNAME + "</td>";
    				rmHtml += "<td>" + pay.SUBNAME + "/" + pay.KNAME  + "</td>";
    				rmHtml += "<td>" + pay.STATUS + "</td>";
    				
    				// 결제 실패 빨간색 처리.
    				if(pay.PSTATUS == '결제실패')
    					rmHtml += "<td><span style='color:red;'>" + pay.PSTATUS + "</span></td>";
    				else
    					rmHtml += "<td>" + pay.PSTATUS + "</td>";
    				
    				// 결제 취소 맹글어보기.
    				if( pay.PSTATUS == "결제완료" && ( pay.STATUS == '모집 마감' || pay.STATUS == "마감 임박" || pay.STATUS == "모집 중"))
    					rmHtml += "<td><button type='button' onclick='lectureCancel(" + pay.SNO + "," + pay.MNO + "," + pay.PNO + "," + pay.PRICE + ")'>결제 취소</button></td>";	
    				else if(pay.PSTATUS == "결제완료" && ( pay.STATUS == "진행 중" || pay.STATUS == "강의 종료"))
    					rmHtml += "<td>" + pay.PSTATUS + "</td>";
   					else if( pay.PSTATUS == "결제실패" )
   						rmHtml += "<td><span style='color:red;'>"+ pay.PSTATUS + "</span></td>";
					else if( pay.PSTATUS == "결제취소" )
	  						rmHtml += "<td>"+ pay.PSTATUS + "</td>";
    			rmHtml += "</tr>";
	    	}
			$(".table-responsive tbody").html(rmHtml);

		},error:function(){
			
		}
	});
}

function lectureCancel(sno, mno, originNo, price){
	if(confirm("결제를 취소하시겠습니까?")){
		$.ajax({
			url : "${rootPath}/lecture/lectureCancel.do",
			data : {
				sno : sno,
				mno : mno,
				originNo : originNo,
				price : price
			},
			success : function(data){
				console.log(data);
				location.href="${rootPath}/admin/adminPayment";
			}
		}).done(function(){
			alert("취소 완료");
		});		
	}
}
</script>
   
<div class="payList">
	<div class="table-responsive">
		<table class="table table-striped table-sm">
			<thead>
				<tr>
					<th>No</th>
					<th>제목</th>
					<th>강사명</th>
					<th>등록일</th>
					<th>시작 일자</th>
					<th>강의 요일</th>
					<th>시간</th>
					<th>강의 비용</th>
					<th>신청 인원</th>
					<th>모집 인원</th>
					<th>지역</th>
					<th>과목</th>
					<th>상태</th>
					<th>결제 상태</th>
					<th>비고</th>
				</tr>
			</thead>			
			<tbody>
				
			</tbody>
		</table>
	</div>
	<nav aria-label="Page navigation example">
	  <ul class="pagination">
	    <li class="page-item">
	    	<a class="page-link" href="#">Next</a>
	    </li>
	  </ul>
	</nav>
</div>   	
   
<jsp:include page="/WEB-INF/views/common/admin_footer.jsp"/>   