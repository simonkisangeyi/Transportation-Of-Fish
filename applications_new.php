<?php
require __DIR__ . '/db_connect.php';

$orders = [];
$fishTypes = [];
$destinations = [];

try {
    $fishTypes = $pdo->query('SELECT fish_type_id, name FROM fish_types ORDER BY name')->fetchAll();
    $destinations = $pdo->query('SELECT destination_id, name FROM destinations ORDER BY name')->fetchAll();
} catch (PDOException $e) {
    http_response_code(500);
    echo '<h1>Unable to load transport configuration</h1>';
    echo '<p>' . htmlspecialchars($e->getMessage(), ENT_QUOTES, 'UTF-8') . '</p>';
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $fullname = trim((string)($_POST['fullname'] ?? ''));
    $phone = trim((string)($_POST['phone'] ?? ''));
    $fish_type_id = (int)($_POST['fish_type'] ?? 0);
    $weight = (int)($_POST['weight'] ?? 0);
    $destination_id = (int)($_POST['destination'] ?? 0);
    $delivery_date = trim((string)($_POST['delivery_date'] ?? ''));
    $instructions = trim((string)($_POST['instructions'] ?? ''));

    if ($fullname !== '' && $phone !== '' && $fish_type_id > 0 && $weight > 0 && $destination_id > 0 && $delivery_date !== '') {
        $customerStmt = $pdo->prepare('SELECT customer_id FROM customers WHERE phone = ? LIMIT 1');
        $customerStmt->execute([$phone]);
        $customerId = $customerStmt->fetchColumn();

        if (!$customerId) {
            $insertCustomer = $pdo->prepare('INSERT INTO customers (fullname, phone, email, region) VALUES (?, ?, NULL, NULL)');
            $insertCustomer->execute([$fullname, $phone]);
            $customerId = $pdo->lastInsertId();
        }

        $orderStmt = $pdo->prepare('INSERT INTO orders (customer_id, fish_type_id, destination_id, weight_kg, delivery_date, instructions, status) VALUES (?, ?, ?, ?, ?, ?, ?)');
        $orderStmt->execute([$customerId, $fish_type_id, $destination_id, $weight, $delivery_date, $instructions, 'Pending']);
    }

    header('Location: ' . $_SERVER['REQUEST_URI']);
    exit;
}

try {
    $orders = $pdo->query(
        'SELECT o.order_id, c.fullname, c.phone, f.name AS fish_type, d.name AS destination, o.weight_kg, o.delivery_date, o.instructions, o.status
         FROM orders o
         JOIN customers c ON o.customer_id = c.customer_id
         JOIN fish_types f ON o.fish_type_id = f.fish_type_id
         JOIN destinations d ON o.destination_id = d.destination_id
         ORDER BY o.order_id DESC'
    )->fetchAll();
} catch (PDOException $e) {
    http_response_code(500);
    echo '<h1>Unable to load order list</h1>';
    echo '<p>' . htmlspecialchars($e->getMessage(), ENT_QUOTES, 'UTF-8') . '</p>';
    exit;
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Mwanza Fresh Fish | Delivery Booking</title>
  <style>
    body {
      margin: 0;
      font-family: 'Helvetica Neue', Arial, sans-serif;
      background: #f8f5f0;
      color: #2a2a2a;
    }

    .page-wrapper {
      max-width: 1200px;
      margin: 0 auto;
      padding: 24px;
    }

    .hero {
      text-align: center;
      padding: 32px 16px;
      margin-bottom: 16px;
      background: linear-gradient(135deg, #0e5c3b 0%, #17956b 100%);
      color: white;
      border-radius: 20px;
      box-shadow: 0 16px 40px rgba(0, 0, 0, 0.12);
    }

    .hero h1 {
      font-size: clamp(2.5rem, 4vw, 4rem);
      margin: 0 0 16px;
      letter-spacing: 0.02em;
    }

    .hero p {
      margin: 0;
      font-size: 1.05rem;
      opacity: 0.92;
    }

    .layout {
      display: grid;
      gap: 24px;
      grid-template-columns: minmax(0, 1.1fr) minmax(0, 0.9fr);
      align-items: start;
    }

    .card {
      background: white;
      border-radius: 26px;
      box-shadow: 0 18px 40px rgba(20, 40, 60, 0.08);
      padding: 26px;
    }

    .form-card {
      display: grid;
      gap: 18px;
    }

    .form-card h2,
    .orders h2 {
      margin: 0 0 12px;
      font-size: 1.5rem;
      letter-spacing: 0.01em;
    }

    .field {
      display: grid;
      gap: 8px;
    }

    .field label {
      font-size: 0.95rem;
      font-weight: 700;
      display: inline-flex;
      gap: 0.4rem;
      align-items: center;
    }

    .field input,
    .field select,
    .field textarea {
      width: 100%;
      border: 1px solid #d7d3cd;
      border-radius: 16px;
      padding: 14px 18px;
      font-size: 1rem;
      background: #faf7f2;
      outline: none;
      transition: border-color 0.2s ease;
    }

    .field input:focus,
    .field select:focus,
    .field textarea:focus {
      border-color: #17956b;
      background: #fff;
    }

    .field textarea {
      min-height: 120px;
      resize: vertical;
    }

    .price-box {
      display: grid;
      gap: 8px;
      padding: 20px;
      border: 1px solid #e5e0d9;
      border-radius: 20px;
      background: #fcfbf8;
    }

    .price-box strong {
      font-size: 1.4rem;
      display: block;
      margin-bottom: 4px;
    }

    .price-box span {
      color: #6b6b6b;
      font-size: 0.95rem;
    }

    .submit-btn {
      width: 100%;
      border: none;
      border-radius: 20px;
      padding: 16px;
      background: #0e5c3b;
      color: white;
      font-size: 1.05rem;
      font-weight: 700;
      cursor: pointer;
      transition: transform 0.2s ease, box-shadow 0.2s ease;
    }

    .submit-btn:hover {
      transform: translateY(-1px);
      box-shadow: 0 12px 24px rgba(14, 92, 59, 0.25);
    }

    .note-box {
      background: #f4faf6;
      color: #2f4f3b;
      border-radius: 18px;
      padding: 18px;
      border: 1px solid #dbe7dd;
      font-size: 0.98rem;
      line-height: 1.6;
    }

    .orders {
      display: grid;
      gap: 18px;
    }

    .order-card {
      padding: 20px;
      border-radius: 20px;
      border: 1px solid #ece8e2;
      background: linear-gradient(180deg, #ffffff 0%, #f7f6f3 100%);
      display: grid;
      gap: 10px;
    }

    .order-card h3 {
      margin: 0;
      font-size: 1.1rem;
    }

    .order-row {
      display: flex;
      justify-content: space-between;
      flex-wrap: wrap;
      gap: 8px;
      color: #444;
      font-size: 0.98rem;
    }

    .order-row span {
      display: inline-flex;
      align-items: center;
      gap: 6px;
    }

    .order-status {
      color: #9a5b12;
      font-weight: 700;
    }

    .footer-bar {
      margin-top: 32px;
      text-align: center;
      color: #5c5c5c;
      font-size: 0.95rem;
    }

    @media (max-width: 960px) {
      .layout {
        grid-template-columns: 1fr;
      }
    }

    @media (max-width: 640px) {
      .hero {
        padding: 24px 14px;
        border-radius: 18px;
      }

      .field input,
      .field select,
      .field textarea {
        padding: 12px 14px;
      }

      .submit-btn {
        padding: 14px;
      }
    }
  </style>
</head>
<body>
  <div class="page-wrapper">
    <div class="hero">
      <h1>🐟 Mwanza Fresh Fish</h1>
      <p>Delivery Booking • Fresh from Lake Victoria • Delivered anywhere outside Mwanza region</p>
    </div>

    <div class="layout">
      <section class="card form-card">
        <h2> Place Your Order</h2>

        <form id="orderForm" method="post">
          <div class="field">
            <label> Full Name *
              <input type="text" name="fullname" placeholder="Enter your full name" required />
            </label>
          </div>

          <div class="field">
            <label> Phone Number *
              <input type="tel" name="phone" placeholder="0754 123 456" required />
            </label>
          </div>

          <div class="field">
            <label>🐟 Type of Fish *
              <select name="fish_type" required>
                <?php foreach ($fishTypes as $type): ?>
                  <option value="<?php echo (int)$type['fish_type_id']; ?>"><?php echo htmlspecialchars($type['name'], ENT_QUOTES, 'UTF-8'); ?></option>
                <?php endforeach; ?>
              </select>
            </label>
          </div>

          <div class="field">
            <label> Weight (kg) *
              <input type="number" name="weight" min="1" value="10" required />
            </label>
          </div>

          <div class="field">
            <label> Destination *
              <select name="destination" required>
                <?php foreach ($destinations as $destination): ?>
                  <option value="<?php echo (int)$destination['destination_id']; ?>"><?php echo htmlspecialchars($destination['name'], ENT_QUOTES, 'UTF-8'); ?></option>
                <?php endforeach; ?>
              </select>
            </label>
          </div>

          <div class="field">
            <label> Delivery Date *
              <input type="date" name="delivery_date" value="2026-06-15" required />
            </label>
          </div>

          <div class="field">
            <label> Special Instructions (Optional)
              <textarea name="instructions" placeholder="Enter any delivery instructions..."></textarea>
            </label>
          </div>

          <div class="price-box">
            <strong> Estimated Delivery Cost</strong>
            <span>TZS 25,000</span>
            <span>*Price includes cold chain transport</span>
          </div>

          <button class="submit-btn" type="submit"> Submit Order Now</button>
        </form>

        <div class="note-box">
          <strong> Note:</strong> Orders outside Mwanza region take 24-48 hours. Freshness guaranteed with ice-packed cooling system (0-4°C).
        </div>
      </section>

      <aside class="orders">
        <div class="card">
          <h2> Customer Orders</h2>
        </div>

        <?php
        // Show existing orders (newest last)
        foreach ($orders as $o):
        ?>
        <article class="order-card">
          <h3><?php echo htmlspecialchars($o['fullname']); ?></h3>
          <div class="order-row">
            <span>🐟 <?php echo htmlspecialchars($o['fish_type']); ?> | <?php echo (int)$o['weight_kg']; ?> kg</span>
            <span> <?php echo htmlspecialchars($o['destination']); ?></span>
          </div>
          <div class="order-row">
            <span> Deliver by: <?php echo htmlspecialchars($o['delivery_date']); ?></span>
            <span> TZS —</span>
          </div>
          <div class="order-row">
            <span> <?php echo htmlspecialchars($o['phone']); ?></span>
            <span class="order-status"> Pending Delivery</span>
          </div>
        </article>
        <?php endforeach; ?>
      </aside>
    </div>

    <div class="footer-bar">
      © 2026 Mwanza Fresh Fish | Delivering fresh fish from Lake Victoria to all regions outside Mwanza
    </div>
  </div>
</body>
</html>
