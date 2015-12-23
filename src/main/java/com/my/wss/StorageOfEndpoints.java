package com.my.wss;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class StorageOfEndpoints {

	private static final StorageOfEndpoints STORAGE_OF_ENDPOINTS = new StorageOfEndpoints();

	private static Map<String, MyWss> storage;

	private StorageOfEndpoints() {
		storage = new ConcurrentHashMap<String, MyWss>(200);
	}

	public Map<String, MyWss> getStorage() {
		return storage;
	}

	public static StorageOfEndpoints getStorageOfEndpoints() {
		return STORAGE_OF_ENDPOINTS;
	}
}
