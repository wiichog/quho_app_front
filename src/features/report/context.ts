/**
 * Captura automática de contexto para los reportes desde la app móvil.
 */
import Constants from 'expo-constants';
import * as Application from 'expo-application';
import * as Device from 'expo-device';
import { Platform } from 'react-native';

export interface DeviceContext {
  surface: 'mobile_ios' | 'mobile_android';
  app_version: string;
  build_number: string;
  os_version: string;
  device_model: string;
}

export function collectDeviceContext(): DeviceContext {
  return {
    surface: Platform.OS === 'ios' ? 'mobile_ios' : 'mobile_android',
    app_version:
      Constants.expoConfig?.version ?? Application.nativeApplicationVersion ?? '',
    build_number: Application.nativeBuildVersion ?? '',
    os_version: `${Platform.OS} ${Device.osVersion ?? Platform.Version ?? ''}`.trim(),
    device_model: Device.modelName ?? '',
  };
}
