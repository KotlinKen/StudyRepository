package com.pure.study.board.controller;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import com.pure.study.board.model.excption.BoardException;
import com.pure.study.board.model.service.BoardService;
import com.pure.study.board.model.vo.Attachment;
import com.pure.study.board.model.vo.Board;

@Controller
public class BoardController {

	@Autowired
	BoardService boardService;
	
	Logger logger = LoggerFactory.getLogger(getClass());
	
	@RequestMapping("/board/boardList")
	public ModelAndView selectBoardList(@RequestParam (value="cPage", required=false, defaultValue="1") int cPage, @RequestParam (value="type", required=false) String type) {
		ModelAndView mav = new ModelAndView();
		//Rowbounds 처리를 위해서 offset, limit 값이 필요함.
		int numPerPage = 10; 
		
		
		Map<String, String> params = new HashMap<>();
		
		params.put("type", type);
		
		//1. 현재 페이지 컨텐츠 구하기
		List<Map<String, String>> list = boardService.selectBoardList(cPage, numPerPage, params);
		
		logger.debug("보드 리스트 값을 알려주세요"+list);
		
		//2. 페이지바 처리를 위한 전체 컨텐츠수 구하기
		int totalBoardNumber = boardService.selectCount();
		
		mav.addObject("count", totalBoardNumber);
		mav.addObject("list", list);
		mav.addObject("numPerPage", numPerPage);
		
		return mav;
	};
	
	@RequestMapping("/board/boardWrite")
	public void boardForm() {
		//ViewNameTranslator가 자동으로 view단 지정 - 내부적으로 동작하는 requestMapping이 return 타입의 String과 같을경우
		
	}
	
	@RequestMapping("/board/boardWriteEnd")
	public ModelAndView insertBoard(Board board, @RequestParam(value="upFile", required=false) MultipartFile[] upFiles, HttpServletRequest request) {
		ModelAndView mav = new ModelAndView();
		List<String> images = new ArrayList<String>();
		
		try {
			//1.파일업로드 처리
			String saveDirectory = request.getSession().getServletContext().getRealPath("/resources/upload/board");
					
			List<Attachment> attachList = new ArrayList<>();
			
			for(MultipartFile f : upFiles) {
				if(!f.isEmpty()) {
					//파일명 재생성
					String originalFileName = f.getOriginalFilename();
					String ext = originalFileName.substring(originalFileName.lastIndexOf(".")+1);
					SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_HHmmssSSS");
					int rndNum = (int)(Math.random() * 1000);
					String renamedFileName = sdf.format(new Date(System.currentTimeMillis())) + "_" + rndNum + "." + ext;
					
					try {
						f.transferTo(new File(saveDirectory + "/" + renamedFileName));
					} catch (IllegalStateException e) {
						e.printStackTrace();
					} catch (IOException e) {
						e.printStackTrace();
					}
					//VO객체 담기
					images.add(renamedFileName);
				}
			}
			String image  = String.join(",", images);
			board.setUpfile(image);
			
			
			int result = boardService.insertBoard(board, attachList);
			
			
			//3. view단 분기
			String loc = "/";
			String msg = "";
			
			if(result>0) {
				msg = "게시물 등록 성공";
				//loc = "/board/boardView.do?boardNo="+board.getBno();
				loc = "/";
			}else {
				msg = "게시물 등록 실패";
			}
			
			mav.addObject("msg", msg);
			mav.addObject("loc", loc);
			mav.setViewName("common/msg");
		} catch(Exception e) {
			throw new BoardException("게시물 등록 오류");
		}
		return mav;
	}
	
	
	@RequestMapping("/board/boardView")
	public ModelAndView selectOne(@RequestParam int bno) {
		ModelAndView mav = new ModelAndView();
		
		Map<String, String> board = boardService.selectOne(bno);
		
		mav.addObject("board", board);
		return mav;
	}
	
	
	@RequestMapping("/board/boardDownload.do")
	   public void fileDownload(@RequestParam String oName,
	                     @RequestParam String rName,
	                     HttpServletRequest request,
	                     HttpServletResponse response) {
	      logger.debug("파일 다운로드 페이지["+oName+", "+rName+"]");
	      BufferedInputStream bis = null;
	      ServletOutputStream sos = null;
	      String saveDirectory = request.getSession().getServletContext().getRealPath("/resources/upload/board");
	      
	      File savedFile = new File(saveDirectory+"/"+rName);
	      try {
	         bis = new BufferedInputStream(new FileInputStream(savedFile));
	         sos = response.getOutputStream();
	         
	         //응답 세팅
	         response.setContentType("application/octet-stream; charset=utf-8");
	         
	         //한글 파일명 처리
	         String resFilename = "";
	         boolean isMSIE = request.getHeader("user-agent").indexOf("MSIE") != -1 ||
	                     request.getHeader("user-agent").indexOf("Trident") != -1;
	         
	         if(isMSIE) {
	            //ie는 utf-8 인코딩을 명시적으로 해줌.
	            resFilename = URLEncoder.encode(oName, "utf-8");
	            resFilename = resFilename.replaceAll("\\+", "%20");
	         } else {
	            resFilename = new String(oName.getBytes("utf-8"),"ISO-8859-1");
	         }
	         logger.debug("resFilename="+resFilename);
	         response.addHeader("Content-Disposition", "attachment; filename=\""+resFilename+"\"");
	         
	         //쓰기
	         int read = 0;
	         while((read=bis.read())!=-1) {
	            sos.write(read);
	         }
	         
	      }catch(IOException e) {
	         e.printStackTrace();
	      } finally {
	         try {
	            sos.close();
	            bis.close();
	         } catch(IOException e) {
	            e.printStackTrace();
	         }
	      }
	      
	      
	      
	      
	      
	   }
}
