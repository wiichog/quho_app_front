import { MaterialIcons } from '@expo/vector-icons';
import {
  ActivityIndicator,
  Pressable,
  PressableProps,
  StyleSheet,
  Text,
  View,
  ViewStyle,
} from 'react-native';
import { colors, radius, spacing, text } from '@/theme';

type Variant = 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger' | 'accent';
type Size = 'sm' | 'md' | 'lg';

export interface ButtonProps extends Omit<PressableProps, 'children' | 'style'> {
  title: string;
  variant?: Variant;
  size?: Size;
  loading?: boolean;
  fullWidth?: boolean;
  icon?: keyof typeof MaterialIcons.glyphMap;
  style?: ViewStyle;
}

const HEIGHT: Record<Size, number> = { sm: 40, md: 52, lg: 56 };

export function Button({
  title,
  variant = 'primary',
  size = 'md',
  loading = false,
  fullWidth = true,
  icon,
  disabled,
  style,
  ...rest
}: ButtonProps) {
  const isDisabled = disabled || loading;
  const palette = getPalette(variant, isDisabled);

  return (
    <Pressable
      accessibilityRole="button"
      disabled={isDisabled}
      style={({ pressed }) => [
        styles.base,
        {
          height: HEIGHT[size],
          backgroundColor: palette.bg,
          borderColor: palette.border,
          borderWidth: palette.border === 'transparent' ? 0 : 1.5,
          opacity: pressed ? 0.85 : 1,
          alignSelf: fullWidth ? 'stretch' : 'flex-start',
        },
        style,
      ]}
      {...rest}
    >
      {loading ? (
        <ActivityIndicator color={palette.fg} />
      ) : (
        <View style={styles.row}>
          {icon ? <MaterialIcons name={icon} size={20} color={palette.fg} /> : null}
          <Text style={[text.button(palette.fg), styles.label]}>{title}</Text>
        </View>
      )}
    </Pressable>
  );
}

function getPalette(variant: Variant, disabled: boolean) {
  if (disabled) {
    return { bg: colors.gray200, fg: colors.gray400, border: 'transparent' };
  }
  switch (variant) {
    case 'primary':
      return { bg: colors.purple, fg: colors.white, border: 'transparent' };
    case 'accent':
      return { bg: colors.purple, fg: colors.white, border: 'transparent' };
    case 'secondary':
      return { bg: colors.darkNavy, fg: colors.white, border: 'transparent' };
    case 'outline':
      return { bg: colors.white, fg: colors.purple, border: colors.purple };
    case 'ghost':
      return { bg: 'transparent', fg: colors.purple, border: 'transparent' };
    case 'danger':
      return { bg: colors.red, fg: colors.white, border: 'transparent' };
    default:
      return { bg: colors.purple, fg: colors.white, border: 'transparent' };
  }
}

const styles = StyleSheet.create({
  base: {
    borderRadius: radius.xs,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: spacing.lg,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.xs,
  },
  label: { textTransform: 'uppercase', letterSpacing: 1 },
});
