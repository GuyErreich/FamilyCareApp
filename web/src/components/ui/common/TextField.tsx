import type { InputHTMLAttributes, ReactNode, TextareaHTMLAttributes } from "react";

interface TextFieldProps {
  label: string;
  error?: string;
  children?: ReactNode;
}

export function TextField({ label, error, children }: TextFieldProps) {
  return (
    <label className={["field", error ? "field--error" : ""].filter(Boolean).join(" ")}>
      <span className="field__label">{label}</span>
      {children}
      {error ? <span className="error-text">{error}</span> : null}
    </label>
  );
}

interface TextInputProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
}

export function TextInput({ label, error, className, ...props }: TextInputProps) {
  return (
    <TextField label={label} error={error}>
      <input className={["text-field__input", className].filter(Boolean).join(" ")} {...props} />
    </TextField>
  );
}

interface TextAreaProps extends TextareaHTMLAttributes<HTMLTextAreaElement> {
  label: string;
  error?: string;
}

export function TextArea({ label, error, ...props }: TextAreaProps) {
  return (
    <TextField label={label} error={error}>
      <textarea {...props} />
    </TextField>
  );
}
