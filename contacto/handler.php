<?php
// =======================================
// handler.php  — JMG Topografía
// Formulario de contacto seguro con AJAX
// =======================================

// CONFIGURACIÓN
$to = "info@jmgtopografia.com"; // Cambiar si deseas otro correo receptor
$subject_prefix = "[Contacto Web] ";

// ---------------------------------------
// Función de sanitización
// ---------------------------------------
function clean($str) {
    return trim(substr(filter_var($str, FILTER_SANITIZE_STRING), 0, 1000));
}

// ---------------------------------------
// Verifica método HTTP
// ---------------------------------------
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(405);
    echo json_encode(["ok" => false, "errors" => ["Método no permitido."]]);
    exit;
}

// ---------------------------------------
// Honeypot (campo invisible para bots)
// Si se completa, es SPAM y se rechaza
// ---------------------------------------
if (!empty($_POST["website"])) {
    http_response_code(400);
    echo json_encode(["ok" => false, "errors" => ["Acceso no válido detectado."]]);
    exit;
}

// ---------------------------------------
// Captura y validación de campos
// ---------------------------------------
$name    = isset($_POST["name"])    ? clean($_POST["name"]) : "";
$email   = isset($_POST["email"])   ? filter_var(trim($_POST["email"]), FILTER_VALIDATE_EMAIL) : false;
$subject = isset($_POST["subject"]) ? clean($_POST["subject"]) : "Consulta web";
$message = isset($_POST["message"]) ? trim($_POST["message"]) : "";

$errors = [];

if (!$name)    $errors[] = "El nombre es obligatorio.";
if (!$email)   $errors[] = "El email no es válido.";
if (!$message) $errors[] = "El mensaje no puede estar vacío.";

if (!empty($errors)) {
    http_response_code(400);
    echo json_encode(["ok" => false, "errors" => $errors], JSON_UNESCAPED_UNICODE);
    exit;
}

// ---------------------------------------
// Construcción del correo
// ---------------------------------------
$full_subject = $subject_prefix . $subject;

$body = 
"Nuevo mensaje desde el formulario web de JMG Topografía:\n\n" .
"Nombre: $name\n" .
"Email: $email\n" .
"Asunto: $subject\n\n" .
"Mensaje:\n$message\n";

$headers =
"From: $name <$email>\r\n" .
"Reply-To: $email\r\n" .
"Content-Type: text/plain; charset=utf-8\r\n";

// ---------------------------------------
// Envío del correo
// ---------------------------------------
$sent = mail($to, $full_subject, $body, $headers);

// ---------------------------------------
// Respuesta
// ---------------------------------------
if ($sent) {
    echo json_encode(["ok" => true, "message" => "Mensaje enviado correctamente. ¡Gracias por contactarnos!"]);
    exit;
}

http_response_code(500);
echo json_encode(["ok" => false, "errors" => ["No se pudo enviar el mensaje. Inténtalo más tarde."]]);
exit;
?>
