import { MaterialIcons } from '@expo/vector-icons';
import { useState } from 'react';
import {
  Pressable,
  StyleSheet,
  TextInput,
  TextInputProps,
  View,
} from 'react-native';
import { colors, radius, spacing, text } from '@/theme';
import { Text } from './Text';

export interface TextFieldProps extends TextInputProps {
  label?: string;
  error?: string;
  leftIcon?: keyof typeof MaterialIcons.glyphMap;
  /** Activa el botón de mostrar/ocultar para contraseñas. */
  password?: boolean;
}

export function TextField({
  label,
  error,
  leftIcon,
  password = false,
  style,
  ...rest
}: TextFieldProps) {
  const [focused, setFocused] = useState(false);
  const [hidden, setHidden] = useState(password);

  const borderColor = error ? colors.red : focused ? colors.teal : colors.gray200;

  return (
    <View style={styles.wrapper}>
      {label ? (
        <Text variant="caption" color={colors.gray600} style={styles.label}>
          {label}
        </Text>
      ) : null}
      <View style={[styles.field, { borderColor }]}>
        {leftIcon ? (
          <MaterialIcons name={leftIcon} size={20} color={colors.gray400} style={styles.leftIcon} />
        ) : null}
        <TextInput
          style={[styles.input, text.bodyMedium(colors.gray900), style]}
          placeholderTextColor={colors.gray400}
          secureTextEntry={hidden}
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
          {...rest}
        />
        {password ? (
          <Pressable onPress={() => setHidden((h) => !h)} hitSlop={8}>
            <MaterialIcons
              name={hidden ? 'visibility-off' : 'visibility'}
              size={20}
              color={colors.gray400}
            />
          </Pressable>
        ) : null}
      </View>
      {error ? (
        <Text variant="caption" color={colors.red} style={styles.error}>
          {error}
        </Text>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: { marginBottom: spacing.md },
  label: { marginBottom: spacing.xxs },
  field: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.white,
    borderWidth: 1.5,
    borderRadius: radius.xs,
    paddingHorizontal: spacing.md,
    height: 52,
  },
  leftIcon: { marginRight: spacing.xs },
  input: { flex: 1, height: '100%' },
  error: { marginTop: spacing.xxs },
});
