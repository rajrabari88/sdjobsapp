<?php
header('Content-Type: application/json');
require_once 'config.php';

// Get request data
$user_id = $_POST['user_id'] ?? '';
$job_id = $_POST['job_id'] ?? '';
$name = $_POST['name'] ?? '';
$email = $_POST['email'] ?? '';
$phone = $_POST['phone'] ?? '';
$cover_letter = $_POST['cover_letter'] ?? '';
$experience = $_POST['experience'] ?? '';
$additional_notes = $_POST['additional_notes'] ?? '';

// Validate required fields
if (empty($user_id) || empty($job_id) || empty($email)) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error',
        'message' => 'Missing required fields'
    ]);
    exit();
}

try {
    // Insert application record
    $stmt = $pdo->prepare("
        INSERT INTO job_applications (
            user_id, 
            job_id, 
            name, 
            email, 
            phone, 
            cover_letter, 
            experience, 
            additional_notes, 
            applied_at
        ) VALUES (
            :user_id, 
            :job_id, 
            :name, 
            :email, 
            :phone, 
            :cover_letter, 
            :experience, 
            :additional_notes, 
            NOW()
        )
    ");

    $stmt->execute([
        ':user_id' => $user_id,
        ':job_id' => $job_id,
        ':name' => $name,
        ':email' => $email,
        ':phone' => $phone,
        ':cover_letter' => $cover_letter,
        ':experience' => $experience,
        ':additional_notes' => $additional_notes
    ]);

    // Also update user's applied jobs count
    $stmt2 = $pdo->prepare("
        UPDATE users 
        SET applied_jobs_count = applied_jobs_count + 1
        WHERE id = :user_id
    ");
    $stmt2->execute([':user_id' => $user_id]);

    http_response_code(200);
    echo json_encode([
        'status' => 'success',
        'message' => 'Application submitted successfully!',
        'application_id' => $pdo->lastInsertId()
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Database error: ' . $e->getMessage()
    ]);
}
?>
