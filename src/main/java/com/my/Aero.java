package com.my;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.websocket.Session;

import org.apache.commons.lang3.RandomStringUtils;
import org.json.simple.JSONValue;

import com.my.wss.MyWss;
import com.my.wss.StorageOfEndpoints;

public class Aero extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static Map<String, List<String>> mapEndpointsForTranslation = new ConcurrentHashMap<String, List<String>>();

	StorageOfEndpoints initialStorageOfEndpoints = StorageOfEndpoints
			.getStorageOfEndpoints();



	@Override
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		List<String> list = null;
		
		if (request.getParameter("watch") != null) {
			if (request.getParameter("watch").equals("false")) {

			list = new LinkedList<String>();
			
				for (String str : MyWss.getListOfIdWhichIsConnected().keySet()) {
					if (!str.contains("dop")) {
						list.add(str);
					}
				}
				String jsonText = JSONValue.toJSONString(list);
				response.setContentType("Content-type: application/json");
				response.setCharacterEncoding("UTF-8");
				response.getWriter().println(jsonText);
			}
			if (request.getParameter("watch").equals("true")
					&& request.getParameter("idForTrans") != null) {

				System.out.println(request.getParameter("idForTrans") + "ID"
						+ request.getParameter("myId"));
				String idFirstEndpoints = request.getParameter("idForTrans");
				String idSecondEndpoints = MyWss.getListOfIdWhichIsConnected()
						.get(idFirstEndpoints);
				String idSessionForTranslation = request.getParameter("myId");
				makeBroadcasting(idFirstEndpoints, idSecondEndpoints,
						idSessionForTranslation);
			}

			if (request.getParameter("watch").equals("stop")) {
				String idSessionForTranslation = request.getParameter("myId");
				stopBroadcasting(idSessionForTranslation);

			}

			return;
		}

		if (request.getParameter("game") != null) {
			String action = request.getParameter("game");
			String clientId = request.getParameter("clientId");
			String opponentId = request.getParameter("opponentId");
			String clientIddop = request.getParameter("clientIddop");
			String opponentIddop = request.getParameter("opponentIddop");

			if (action.equals("start")) {
				connectTwoSession(clientId, opponentId);
				connectTwoSession(clientIddop, opponentIddop);
			}
			if (action.equals("stop")) {
				disConnectTwoSession(clientId, opponentId);
				disConnectTwoSession(clientIddop, opponentIddop);
			}

		}
		String rId = RandomStringUtils.randomAlphanumeric(10);
		request.setAttribute("rId", rId);

		if (request.getParameter("opponentId") != null) {
			request.setAttribute("rId", rId);
			request.setAttribute("opponentId",
					request.getParameter("opponentId"));
		}

		RequestDispatcher rq = request.getRequestDispatcher("aero.jsp");
		rq.forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
	}

	private void connectTwoSession(String clientId, String opponentId) {
		MyWss.getListOfIdWhichIsConnected().put(clientId, opponentId);
		MyWss.getListOfIdWhichIsConnected().put(opponentId, clientId);
		long time = System.currentTimeMillis();
		MyWss.getStorageOfEndpoints().get(opponentId)
				.setSession(clientId, time);
		MyWss.getStorageOfEndpoints().get(clientId)
				.setSession(opponentId, time);
	}

	private void disConnectTwoSession(String clientId, String opponentId) {
		MyWss.getStorageOfEndpoints().get(opponentId)
				.unSetSession(clientId, "stop");
		MyWss.getStorageOfEndpoints().get(clientId)
				.unSetSession(opponentId, "stop");
		MyWss.getListOfIdWhichIsConnected().remove(clientId);
		MyWss.getListOfIdWhichIsConnected().remove(opponentId);

	}

	private void makeBroadcasting(String firstId, String secondId,
			String viewerId) {
		ArrayList<String> listOfIdForTrans = new ArrayList<String>();
		listOfIdForTrans.add(firstId);
		listOfIdForTrans.add(firstId + "dop");
		listOfIdForTrans.add(secondId);
		listOfIdForTrans.add(secondId + "dop");
		Session sessionForBroadcasting = MyWss.getSessions().get(viewerId);
		Session dopSessionForBroadcasting = MyWss.getSessions().get(
				viewerId + "dop");
		MyWss firstEndpoint = MyWss.getStorageOfEndpoints().get(firstId);
		MyWss firstEndpointDop = MyWss.getStorageOfEndpoints().get(
				firstId + "dop");
		MyWss secondEndpoint = MyWss.getStorageOfEndpoints().get(secondId);
		MyWss secondEndpointDop = MyWss.getStorageOfEndpoints().get(
				secondId + "dop");
		firstEndpoint.setMarkerForViewer("f");
		firstEndpoint.getViewers().add(sessionForBroadcasting);
		firstEndpointDop.setMarkerForViewer("fd");
		firstEndpointDop.getViewers().add(dopSessionForBroadcasting);
		secondEndpoint.setMarkerForViewer("s");
		secondEndpoint.getViewers().add(sessionForBroadcasting);
		secondEndpointDop.setMarkerForViewer("sd");
		secondEndpointDop.getViewers().add(dopSessionForBroadcasting);
		mapEndpointsForTranslation.put(viewerId, listOfIdForTrans);
	}

	private void stopBroadcasting(String viewerId) {
		Session session = MyWss.getSessions().get(viewerId);
		ArrayList<String> listForRemove = (ArrayList<String>) Aero
				.getMapEndpointsForTranslation().get(viewerId);
		Aero.getMapEndpointsForTranslation().remove(viewerId);
		for (String id : listForRemove) {
			MyWss endpoint = MyWss.getStorageOfEndpoints().get(id);
			endpoint.getViewers().remove(session);
			if (endpoint.getViewers().size() == 0) {
				endpoint.setMarkerForViewer(null);
			}
		}
	}

	public static Map<String, List<String>> getMapEndpointsForTranslation() {
		return mapEndpointsForTranslation;
	}

	public static void setMapEndpointsForTranslation(
			Map<String, List<String>> mapEndpointsForTranslation) {
		Aero.mapEndpointsForTranslation = mapEndpointsForTranslation;
	}

}