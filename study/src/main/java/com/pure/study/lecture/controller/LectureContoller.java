package com.pure.study.lecture.controller;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import com.pure.study.lecture.model.service.LectureService;
import com.pure.study.lecture.model.vo.Lecture;

@Controller
public class LectureContoller {
	private Logger logger = LoggerFactory.getLogger(getClass());

	@Autowired
	private LectureService ls;

	private int numPerPage = 6;

	/* 강의 등록으로 이동하는 맵핑 */
	@RequestMapping("/lecture/insertLecture.do")
	public ModelAndView insertLecture() {
		ModelAndView mav = new ModelAndView();

		// 지역리스트
		List<Map<String, String>> locList = ls.selectLocList();
		// 큰 분류 리스트
		List<Map<String, String>> kindList = ls.selectKindList();
		// 난이도
		List<Map<String, String>> diffList = ls.selectDiff();

		mav.addObject("locList", locList);
		mav.addObject("kindList", kindList);
		mav.addObject("diffList", diffList);

		mav.setViewName("lecture/insertLecture");

		return mav;
	}

	@RequestMapping("/lecture/lectureFormEnd.do")
	public ModelAndView insertLecture(Lecture lecture,
			@RequestParam(value = "cPage", required = false, defaultValue = "1") int cPage,
			@RequestParam(value = "freqs") String[] freqs, @RequestParam(value = "upFile") MultipartFile[] upFiles,
			HttpServletRequest request) {
		ModelAndView mav = new ModelAndView();
		Map<String, Object> key = new HashMap<>();
		key.put("mno", lecture.getMno());
		key.put("key", "study");
		System.out.println("---------------------------------"+lecture);
		int result = 0;
		String msg = "";
		String loc = "/lecture/lectureList";

		List<Map<String, String>> locList = ls.selectLocList();
		List<Map<String, String>> kindList = ls.selectKindList();
		List<Map<String, String>> diffList = ls.selectDiff();

		mav.addObject("locList", locList);
		mav.addObject("kindList", kindList);
		mav.addObject("diffList", diffList);

		// 빈도 배열을 join해서 setter로 setting해줌
		String freq = String.join(",", freqs);
		lecture.setFreqs(freq);

		// 같은 날짜, 요일, 시간에 있는지를 검사해봅시다..
		List<Map<String, Object>> list = ls.selectLectureListByMno(key);
	
		int cnt = checkDate(lecture, list, freqs);

		if (cnt == 0) {
			// 1.파일업로드처리
			int l = 1;
			int last = upFiles.length;

			String img = "";
			String saveDirectory = request.getSession().getServletContext().getRealPath("/resources/upload/lecture");

			/****** MultipartFile을 이용한 파일 업로드 처리로직 시작 ******/
			for (MultipartFile f : upFiles) {
				if (!f.isEmpty()) {
					// 파일명 재생성
					String originalFileName = f.getOriginalFilename();
					String ext = originalFileName.substring(originalFileName.lastIndexOf(".") + 1);
					SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_HHmmssSSS");
					int rndNum = (int) (Math.random() * 1000);
					String renamedFileName = sdf.format(new Date(System.currentTimeMillis())) + "_" + rndNum + "."
							+ ext;

					if (l != last)
						img += renamedFileName + ",";

					if (l == last) {
						img += renamedFileName;
						lecture.setUpfile(img);

						result = ls.insertLecture(lecture);

						if (result > 0) {
							try {
								f.transferTo(new File(saveDirectory + "/" + renamedFileName));
							} catch (IllegalStateException e) {
								e.printStackTrace();
							} catch (IOException e) {
								e.printStackTrace();
							}
						}
					}

					l++;

				} else {
					lecture.setUpfile(img);
					result = ls.insertLecture(lecture);
				}
			}

			msg = "강의가 등록되었습니다.";
		} else {
			msg = "등록하시려는 시간대와 겹치는 강의 또는 스터디가 존재합니다.";
		}

		mav.addObject("msg", msg);
		mav.addObject("loc", loc);

		mav.setViewName("/common/msg");

		return mav;
	}

	@RequestMapping("/lecture/selectTown.do")
	@ResponseBody
	public List<Map<String, Object>> selectTown(@RequestParam(value = "localNo") int localNo) {
		List<Map<String, Object>> townList = ls.selectTownList(localNo);

		return townList;
	}

	@RequestMapping("/lecture/selectSubject.do")
	@ResponseBody
	public List<Map<String, Object>> selectKind(@RequestParam(value = "kindNo") int kindNo) {
		List<Map<String, Object>> subList = ls.selectSubList(kindNo);

		return subList;
	}

	@RequestMapping("/lecture/lectureList.do")
	public ModelAndView lectureList(@RequestParam(value = "cPage", required = false, defaultValue = "1") int cPage,
			@RequestParam(required = false, defaultValue = "0") int mno) {
		ModelAndView mav = new ModelAndView();

		List<Map<String, String>> locList = ls.selectLocList();
		List<Map<String, String>> kindList = ls.selectKindList();
		List<Map<String, String>> diffList = ls.selectDiff();

		int check = 0;

		if (mno > 0)
			check = ls.confirmInstructor(mno);

		mav.addObject("locList", locList);
		mav.addObject("kindList", kindList);
		mav.addObject("diffList", diffList);
		mav.addObject("cPage", cPage);
		mav.addObject("check", check);

		mav.setViewName("lecture/lectureList");

		return mav;
	}

	@RequestMapping("/lecture/lectureView.do")
	public ModelAndView lectureView(@RequestParam int sno,
			@RequestParam(required = false, defaultValue = "0") int mno) {
		ModelAndView mav = new ModelAndView();
		
		
		Map<String, Integer> map = new HashMap<>();
		map.put("sno", sno);

		// 이미 찜이 들어가 있는지, 신청을 했는지 확인.
		if (mno > 0) {
			map.put("mno", mno);
			int wish = ls.lectureWish(map);
			int insert = ls.preinsertApply(map);
			mav.addObject("pre", wish);
			mav.addObject("insert", insert);
		}

		Map<String, String> lecture = ls.selectLectureOne(sno);

		mav.addObject("lecture", lecture);

		mav.setViewName("lecture/lectureView");

		return mav;
	}

	@RequestMapping("/lecture/deleteLecture.do")
	public ModelAndView deleteLecture(@RequestParam int sno) {
		ModelAndView mav = new ModelAndView();
		int result = ls.deleteLecture(sno);

		mav.setViewName("/lecture/lectureList");

		return mav;
	}

	@RequestMapping("/lecture/deleteLectures")
	@ResponseBody
	public int deleteLectures(@RequestParam(value = "lectures[]") List<Integer> lectures) {
		Map<String, Object> map = new HashMap<>();

		map.put("lectures", lectures);

		int result = ls.deleteLectures(map);

		return result;
	}

	@RequestMapping(value="/lecture/findLecture.do", produces="text/plain;charset=UTF-8")
	@ResponseBody
	public String findLecture(@RequestParam int sno, @RequestParam int mno) {
		int result = 0;
		String msg = "";

		Map<String, Integer> preCheck = new HashMap<>();

		preCheck.put("sno", sno);
		preCheck.put("mno", mno);

		// 이미 강의가 들어가 있는지 확인.
		result = ls.preinsertApply(preCheck);

		if (result == 0) {
			Map<String, Object> key = new HashMap<>();

			key.put("mno", mno);
			key.put("key", "crew");

			// mno로 crew쪽 맵 뽑아오기.
			List<Map<String, Object>> list = ls.selectLectureListByMno(key);
			Lecture lecture = ls.selectLectureByMnoTypeLecture(sno);

			try {
				String[] freqs = lecture.getFreqs().split(",");
				int cnt = checkDate(lecture, list, freqs);

				if (cnt != 0) 
					msg = "날짜나 요일, 시간이 겹치는 강의 또는 스터디가 존재합니다.";
				
			} catch (NullPointerException e) {
				msg = "";
			}

		} else {
			msg = "이미 신청한 강의입니다.";
		}

		return msg;
	}

	@RequestMapping("/lecture/applyLecture.do")
	@ResponseBody
	public int applyLecture(@RequestParam int sno, @RequestParam int mno) {
		int result = 0;

		Map<String, Integer> map = new HashMap<>();

		map.put("sno", sno);
		map.put("mno", mno);

		result = ls.applyLecture(map);

		return result;
	}

	// 아무 조건 없이 강의 리스트 첫 페이징 처리.
	@RequestMapping("/lecture/selectLectureList.do")
	public ModelAndView selectLectureList() {
		ModelAndView mav = new ModelAndView("jsonView");

		int cPage = 1;

		List<Map<String, Object>> list = ls.selectLectureList(cPage, numPerPage);

		int total = ls.selectTotalLectureCount();

		mav.addObject("list", list);
		mav.addObject("numPerPage", numPerPage);
		mav.addObject("cPage", cPage + 1);
		mav.addObject("total", total);

		return mav;

	}

	// 스크롤 페이징 처리 - 조건 없음
	@RequestMapping("/lecture/lectureListAdd.do")
	public ModelAndView lectureListAdd(@RequestParam(value = "cPage", defaultValue = "1") int cPage) {
		ModelAndView mav = new ModelAndView("jsonView");
		List<Map<String, Object>> lectureList = ls.selectLectureList(cPage, numPerPage);
		mav.addObject("list", lectureList);
		mav.addObject("cPage", cPage + 1);

		return mav;
	}

	// 검색 첫 페이징 처리
	@RequestMapping("/lecture/searchLecture.do")
	public ModelAndView searchLecture(@RequestParam(value = "lno") int lno,
			@RequestParam(value = "tno", defaultValue = "0") int tno, @RequestParam(value = "kno") int kno,
			@RequestParam(value = "subno", defaultValue = "0") int subno, @RequestParam(value = "dno") int dno,
			@RequestParam(value = "leadername") String leadername,
			@RequestParam(value = "cPage", required = false, defaultValue = "1") int cPage) {
		ModelAndView mav = new ModelAndView("jsonView");

		if (leadername.trim().length() < 1)
			leadername = null;

		/* 쿼리에 넘길 조건들 Map */
		Map<String, Object> terms = new HashMap<>();
		terms.put("lno", lno);
		terms.put("tno", tno);
		terms.put("subno", subno);
		terms.put("kno", kno);
		terms.put("dno", dno);
		terms.put("leadername", leadername);
		terms.put("cPage", cPage);
		terms.put("numPerPage", numPerPage);

		// 검색 조건에 따른 총 스터기 갯수
		int total = ls.selectTotalLectureCountBySearch(terms);

		// 페이징 처리해서 가져온 리스트
		List<Map<String, Object>> lectureList = ls.selectLectureListBySearch(terms);
		mav.addObject("list", lectureList);
		mav.addObject("total", total);
		mav.addObject("cPage", cPage+1);

		return mav;
	}

	// 스크롤 페이징 처리 - 검색
	@RequestMapping("/lecture/lectureSearchAdd.do")
	public ModelAndView lectureSearchAdd(@RequestParam(value = "lno") int lno,
			@RequestParam(value = "tno", defaultValue = "0") int tno, @RequestParam(value = "kno") int kno,
			@RequestParam(value = "subno", defaultValue = "0") int subno, @RequestParam(value = "dno") int dno,
			@RequestParam(value = "leadername") String leadername,
			@RequestParam(value = "cPage", required = false) int cPage) {
		ModelAndView mav = new ModelAndView("jsonView");

		if (leadername.trim().length() < 1)
			leadername = null;

		/* 쿼리에 넘길 조건들 Map */
		Map<String, Object> terms = new HashMap<>();
		terms.put("lno", lno);
		terms.put("tno", tno);
		terms.put("subno", subno);
		terms.put("kno", kno);
		terms.put("dno", dno);
		terms.put("leadername", leadername);
		terms.put("cPage", cPage);
		terms.put("numPerPage", numPerPage);

		List<Map<String, Object>> list = ls.selectLectureListBySearch(terms);
		mav.addObject("list", list);
		mav.addObject("cPage", cPage + 1);

		return mav;
	}

	// 마감입박순 첫 페이징 처리
	@RequestMapping("/lecture/selectByDeadline.do")
	public ModelAndView selectByDeadline() {
		ModelAndView mav = new ModelAndView("jsonView");

		int cPage = 1;

		List<Map<String, Object>> list = ls.selectByDeadline(cPage, numPerPage);

		int total = ls.lectureDeadlineCount();

		mav.addObject("list", list);
		mav.addObject("cPage", cPage + 1);
		mav.addObject("total", total);

		return mav;
	}

	// 스크롤 페이징 처리 - 마감임박순
	@RequestMapping("/lecture/lectureDeadlinAdd.do")
	public ModelAndView lectureDeadlinAdd(@RequestParam(value = "cPage", defaultValue = "1") int cPage) {
		ModelAndView mav = new ModelAndView("jsonView");
		List<Map<String, Object>> lectureList = ls.selectByDeadline(cPage, numPerPage);

		mav.addObject("list", lectureList);
		mav.addObject("cPage", cPage + 1);

		return mav;
	}

	// 신청자순 첫 페이징 처리
	@RequestMapping("/lecture/selectByApply.do")
	public ModelAndView selectByApply() {
		ModelAndView mav = new ModelAndView("jsonView");

		int cPage = 1;

		List<Map<String, Object>> list = ls.selectByApply(cPage, numPerPage);

		int total = ls.studyByApplyCount();

		mav.addObject("list", list);
		mav.addObject("cPage", cPage + 1);
		mav.addObject("total", total);

		return mav;
	}

	// 스크롤 페이징 처리 - 신청자순
	@RequestMapping("/lecture/lectureApplyAdd.do")
	public ModelAndView lectureApplyAdd(@RequestParam(value = "cPage", defaultValue = "1") int cPage) {
		ModelAndView mav = new ModelAndView("jsonView");
		List<Map<String, Object>> lectureList = ls.selectByApply(cPage, numPerPage);
		mav.addObject("list", lectureList);
		mav.addObject("cPage", cPage + 1);

		return mav;
	}

	@RequestMapping("/lecture/lectureWish.do")
	public String lectureWish(@RequestParam int sno, @RequestParam int mno) {
		ModelAndView mav = new ModelAndView();
		Map<String, Integer> map = new HashMap<>();

		map.put("sno", sno);
		map.put("mno", mno);

		int confirm = ls.lectureWish(map);

		if (confirm == 0)
			ls.addWishLecture(map);

		return "redirect:/lecture/lectureView.do?sno=" + sno + "&mno=" + mno;
	}

	@RequestMapping("/lecture/lectureWishCancel.do")
	public String lectureWishCancel(@RequestParam int sno, @RequestParam int mno) {
		Map<String, Integer> map = new HashMap<>();
		ModelAndView mav = new ModelAndView();

		map.put("sno", sno);
		map.put("mno", mno);

		ls.lectureWishCancel(map);

		return "redirect:/lecture/lectureView.do?sno=" + sno + "&mno=" + mno;
	}

	@RequestMapping("/lecture/updateLecture.do")
	public ModelAndView updateLecture(@RequestParam int sno) {
		ModelAndView mav = new ModelAndView();

		// 강의
		Map<String, String> lecture = ls.selectLectureOne(sno);

		// 지역리스트
		List<Map<String, String>> locList = ls.selectLocList();

		// 큰 분류 리스트
		List<Map<String, String>> kindList = ls.selectKindList();

		// 난이도
		List<Map<String, String>> diffList = ls.selectDiff();

		mav.addObject("lecture", lecture);
		mav.addObject("locList", locList);

		mav.addObject("kindList", kindList);
		mav.addObject("diffList", diffList);

		mav.setViewName("lecture/updateLecture");

		return mav;
	}

	@RequestMapping("/lecture/successPay.do")
	public String seccessPay(@RequestParam int mno, @RequestParam int sno, @RequestParam(required = true) long pno,
			@RequestParam int price) {
		Map<String, Object> map = new HashMap<>();

		map.put("pno", pno);
		map.put("sno", sno);
		map.put("mno", mno);
		map.put("price", price);
		map.put("status", 1);

		int result = ls.insertPay(map);

		return "redirect:/lecture/lectureView.do?sno=" + sno + "&mno=" + mno;
	}

	@RequestMapping("/lecture/failedPay.do")
	public String failedPay(@RequestParam int mno, @RequestParam int sno, @RequestParam(required = true) long pno,
			@RequestParam int price) {
		Map<String, Object> map = new HashMap<>();

		map.put("pno", pno);
		map.put("sno", sno);
		map.put("mno", mno);
		map.put("price", price);
		map.put("status", 0);

		int result = ls.insertPay(map);

		return "redirect:/lecture/lectureView.do?sno=" + sno + "&mno=" + mno;
	}


	// 관리자 강의페이지 - 률멘 방식
	@RequestMapping(value = "/lecture/all/{cPage}/{count}", method = RequestMethod.GET)
	@ResponseBody
	public ModelAndView selectLecturePageCount(@PathVariable(value = "count", required = false) int count,
			@PathVariable(value = "cPage", required = false) int cPage) {

		ModelAndView mav = new ModelAndView("jsonView");
		List<Map<String, Object>> list = ls.selectLectureList(cPage, count);
		int total = ls.selectTotalLectureCount();

		mav.addObject("list", list);
		mav.addObject("numPerPage", count);
		mav.addObject("cPage", cPage);
		mav.addObject("total", total);
		return mav;
	}

	public int checkDate(Lecture lecture, List<Map<String, Object>> list, String[] freqs) {
		int cnt = 0;

		if (!list.isEmpty()) {
			// 시간 뽑기
			// 등록 될 시간들.
			long lectureSdate = lecture.getSdate().getTime();
			long lectureEdate = lecture.getEdate().getTime();

			// 뽑아올 시간들.
			String[] times = lecture.getTime().split("~");
			
			int sHour = Integer.parseInt(times[0].split(":")[0]);
			int eHour = Integer.parseInt(times[1].split(":")[0]);

			for (int i = 0; i < list.size(); i++) {
				Date sdate = (Date) list.get(i).get("SDATE");
				Date edate = (Date) list.get(i).get("EDATE");

				// 등록된 날짜들에 포함되지 않는 경우
				if (lectureEdate < sdate.getTime() || lectureSdate > edate.getTime()) {
					System.out.println("날짜가 안겹쳐서 들어감");
				}
				// 포함되는 경우
				else if (lectureSdate >= sdate.getTime() || lectureEdate <= edate.getTime()) {
					// 요일을 검사해보자...
					for (int j = 0; j < freqs.length; j++) {
						if (list.get(i).containsValue(freqs[j])) {
							// 등록이 가능한 경우.
							if (sHour > Integer.parseInt(list.get(j).get("ETIME").toString())
									|| eHour < Integer.parseInt(list.get(j).get("STIME").toString())) {
								System.out.println("시간이 안겹쳐서 들어감");
							}
							// 불가능한 경우.
							else {
								cnt++;
							}
						} else {
							System.out.println("요일이 안겹쳐서 들어감");
						}
					}
				}
			}
		}

		return cnt;
	}

	
	@ResponseBody
	@RequestMapping("/lecture/uploadImage.do")
	public Map<String,String> uploadImage(@RequestParam("file") MultipartFile f,HttpServletRequest request) {

		String renamedFileName="";
		String saveDirectory="";
		Map<String,String> map=new HashMap<>();
	
		try { 
			//1. 파일업로드처리
			saveDirectory = request.getSession().getServletContext().getRealPath("/resources/upload/board");
				if(!f.isEmpty()) {
					//파일명재생성
					String originalFileName = f.getOriginalFilename();
					String ext = originalFileName.substring(originalFileName.lastIndexOf(".")+1);
					SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_HHmmssSSS");
					int rndNum = (int)(Math.random()*1000); //0~9999
					renamedFileName = sdf.format(new Date(System.currentTimeMillis()))+"_"+rndNum+"."+ext;
				
					try {
						f.transferTo(new File(saveDirectory+"/"+renamedFileName)); //실제저장하는코드. 
					} catch (IllegalStateException e) {
						e.printStackTrace();
					} catch (IOException e) {
						e.printStackTrace();
					}
				
				}
			
			}catch(Exception e) {
				throw new RuntimeException("이미지등록오류");
			}
		
		map.put("url", renamedFileName);
		return map;
	}

}