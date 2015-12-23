package com.my.wss;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.websocket.CloseReason;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;

import com.my.Aero;

@ServerEndpoint(value = "/mss/{clientId}")
public class MyWss {

	private static Map<String, Session> sessions = new ConcurrentHashMap<String, Session>();
	private static Map<String, MyWss> storageOfEndpoints = StorageOfEndpoints
			.getStorageOfEndpoints().getStorage();
	private static Map<String, String> listOfIdWhichIsConnected = new ConcurrentHashMap<String, String>();
	private String initialMessage = "Direct connection to the server is established successfully!!!";
	private String clientId;
	private Session opponentSession;
	private List<Session> viwers = new ArrayList<Session>();
	private String markerForviewer;

	@OnOpen
	public void onOpen(@PathParam("clientId") String clientId, Session session) {
		this.clientId = clientId;
		storageOfEndpoints.put(clientId, this);
		sessions.put(clientId, session);
		try {
			session.getBasicRemote().sendText(initialMessage);
			System.out.println("Connected ... " + session.getId());
			System.out.println("Client id: " + clientId);

		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	@OnMessage
	public void onMessage(String message, Session session) {
		try {
			if (opponentSession != null) {
				opponentSession.getBasicRemote().sendText(message);
				if (this.markerForviewer != null) {
					for (Session sess : viwers) {
						sess.getBasicRemote().sendText(
								message + ":" + markerForviewer);
					}
				}

			} else {
				session.getBasicRemote()
						.sendText(
								"You do not have established a connection with an opponent");

			}

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	public void show(String message, Session session) throws IOException {
		session.getBasicRemote().sendText(message);
	}

	@OnClose
	public void onClose(Session session, CloseReason closeReason) {
		storageOfEndpoints.remove(this);
		sessions.remove(clientId);
		if (listOfIdWhichIsConnected.containsKey(this.clientId)) {
			String opponentIdForRemove = listOfIdWhichIsConnected.get(clientId);
			listOfIdWhichIsConnected.remove(clientId);
			listOfIdWhichIsConnected.remove(opponentIdForRemove);
		}
		if (Aero.getMapEndpointsForTranslation().containsKey(clientId)) {
			ArrayList<String> listForRemove = (ArrayList<String>) Aero
					.getMapEndpointsForTranslation().get(clientId);
			Aero.getMapEndpointsForTranslation().remove(clientId);
			for (String id : listForRemove) {
				MyWss endpoint = storageOfEndpoints.get(id);
				endpoint.getViewers().remove(session);
				if (endpoint.getViewers().size() == 0) {
					endpoint.setMarkerForViewer(null);
				}
			}
		}

		System.out.println("remove " + clientId);

	}

	@OnError
	public void onError(Session session, Throwable throwable) {
		// System.out.println("remove " + clientId);
		// listOfId.remove(clientId);

	}

	public static Map<String, Session> getSessions() {
		return sessions;
	}

	public void setSession(String Id, long time) {
		opponentSession = sessions.get(Id);
		try {
			opponentSession.getBasicRemote().sendText("time:" + time);
		} catch (IOException e) {
			System.out.println("Exeption from setSession");
			e.printStackTrace();
		}
	}

	public void unSetSession(String Id, String message) {
		try {
			opponentSession.getBasicRemote().sendText(message);
		} catch (IOException e) {
			System.out.println("Exeption from unSetSession");
			e.printStackTrace();
		}

		opponentSession = null;

	}

	public static Map<String, MyWss> getStorageOfEndpoints() {
		return storageOfEndpoints;
	}

	public String getmarkerForViewer() {
		return markerForviewer;
	}

	public void setMarkerForViewer(String markerForviewer) {
		this.markerForviewer = markerForviewer;
	}

	public static Map<String, String> getListOfIdWhichIsConnected() {
		return listOfIdWhichIsConnected;
	}

	public static void setListOfIdWhichIsConnected(
			Map<String, String> listOfIdWhichIsConnected) {
		MyWss.listOfIdWhichIsConnected = listOfIdWhichIsConnected;
	}

	public List<Session> getViewers() {
		return viwers;
	}
}